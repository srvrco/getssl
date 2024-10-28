INSTALL_DIR=/root
CODE_DIR=/getssl
LIMIT_API="https://api.github.com/rate_limit"

check_certificates()
{
  assert [ -e "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/chain.crt" ]
  assert [ -e "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/fullchain.crt" ]
  assert [ -e "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt" ]
}

# Quota generally shouldn't be an issue - except for tests
# Rate limits are per-IP address
check_github_quota() {
  local need remaining reset limits now
  need="$1"
  echo "# Checking github limits"
  while true ; do
    # shellcheck disable=SC2086
    limits="$(curl ${_NOMETER:---silent} --user-agent "srvrco/getssl/github-actions" -H 'Accept: application/vnd.github.v3+json' "$LIMIT_API")"
    # save error code before calling echo
    errcode=$?
    echo "# limits = $limits"
    if [[ $errcode -eq 60 ]]; then
      echo "curl needs updating, your version does not support SNI (multiple SSL domains on a single IP)"
      exit 1
    elif [[ $errcode -gt 0 ]]; then
      echo "curl error checking releases: $errcode"
      exit 1
    fi
    remaining="$(jq -r '.resources.core.remaining' <<<"$limits")"
    echo "# Remaining: $remaining"
    reset="$(jq -r '.resources.core.reset' <<<"$limits")"
    if [[ "$remaining" -ge "$need" ]] ; then return 0 ; fi
    limit="$(jq -r '.resources.core.limit' <<<"$limits")"
    echo "# Limit: $limit"
    if [[ "$limit" -lt "$need" ]] ; then
      echo "GitHub API request $need exceeds limit $limit"
      exit 1
    fi
    now="$(date +%s)"
    while [[ "$now" -lt "$reset" ]] ; do
      echo "# sleeping $(( reset - now )) seconds for GitHub quota"
      sleep "$(( reset - now ))"
      now="$(date +%s)"
    done
  done
}

# Only nginx > 1.11.0 support dual certificates in a single configuration file
# https://unix.stackexchange.com/questions/285924/how-to-compare-a-programs-version-in-a-shell-script
check_nginx() {
  requiredver="1.11.0"
  currentver=$(nginx -v 2>&1 | awk -F"/" '{print $2}')
  if [ "$(printf '%s\n' "$requiredver" "$currentver" | sort -V | head -n1)" = "$requiredver" ]; then
    export OLD_NGINX="false"
  else
    echo "# INFO: Running nginx version $currentver which doesn't support dual certificates"
    echo "# INFO: not checking that certificate is installed correctly"
    export OLD_NGINX="true"
  fi
}

whitelist_array=(
  "badnonce"
  "DNS problem"
  "acme:error:dns"
)

check_output_for_errors() {
  # check if the output contains a whitelisted phrase, if it does, don't check for the phrase "Error"
  contains_whitelisted_phrase=0
  for phrase in "${whitelist_array[@]}"; do
    echo "# DEBUG: checking output for whitelisted phrase: $phrase"
    status=1
    assert_output --regexp "$phrase" 2>/dev/null || status=0
    contains_whitelisted_phrase=$((status || contains_whitelisted_phrase))
  done

  if [[ $contains_whitelisted_phrase -eq 0 ]]; then
    refute_output --regexp '([Ee][Rr][Rr][Oo][Rr])'
  fi

  refute_output --regexp '[Ff][Aa][Ii][Ll][Ee][Dd]'
  refute_output --regexp '[^_][Ww][Aa][Rr][Nn][Ii][Nn][Gg]'
  refute_line --partial 'command not found'
}

cleanup_environment() {
  if [ -z "$STAGING" ]; then
    curl --silent -X POST -d '{"host":"'"$GETSSL_HOST"'"}' http://10.30.50.3:8055/clear-a
  fi
}

create_certificate() {
  # Create certificate
  cp "${CODE_DIR}/test/test-config/${CONFIG_FILE}" "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl.cfg"
  # shellcheck disable=SC2086
  run ${CODE_DIR}/getssl -U -d "$@" "$GETSSL_CMD_HOST"
}

init_getssl() {
  # Run initialisation (create account key, etc)
  run ${CODE_DIR}/getssl -U -d -c "$GETSSL_CMD_HOST"
  assert_success
  [ -d "$INSTALL_DIR/.getssl" ]
}

setup_environment() {
  # One-off test setup
  if [[ -d ${INSTALL_DIR}/.getssl ]]; then
    rm -r ${INSTALL_DIR}/.getssl
  fi

  if [ -z "$STAGING" ]; then
    # Make sure that we have cleared any previous entries, otherwise get random dns failures
    curl --silent -X POST -d '{"host":"'"$GETSSL_HOST"'"}' http://10.30.50.3:8055/clear-a
    curl --silent -X POST -d '{"host":"'"$GETSSL_HOST"'", "addresses":["'"$GETSSL_IP"'"]}' http://10.30.50.3:8055/add-a
  fi
  cp ${CODE_DIR}/test/test-config/nginx-ubuntu-no-ssl "${NGINX_CONFIG}"
  /getssl/test/restart-nginx
}

# start nginx and vsftpd in background on alpine via supervisord
# shellcheck disable=SC2153 # Ignore GETSSL_OS looks like typo of GETSSL_IP
if [[ -f /usr/bin/supervisord && -f /etc/supervisord.conf ]]; then
  if [[ ! $(pgrep supervisord) ]]; then
    /usr/bin/supervisord -c /etc/supervisord.conf 3>&- 4>&-
    # Give supervisord time to start
    sleep 1
  fi
elif [[ "$GETSSL_OS" == "centos"[78] || "$GETSSL_OS" == "rockylinux"* ]]; then
  if [ -z "$(pgrep nginx)" ]; then
    nginx 3>&- 4>&-
  fi
  if [ -z "$(pgrep vsftpd)" ] && [ "$(command -v vsftpd)" ]; then
    vsftpd 3>&- 4>&-
  fi
fi

# Find NGINX configuration directory for HTTP-01 testing (need to add SSL to config)
if [[ -f /etc/nginx/conf.d/default.conf ]]; then
  export NGINX_CONFIG=/etc/nginx/conf.d/default.conf
elif [[ -f /etc/nginx/http.d/default.conf ]]; then
  export NGINX_CONFIG=/etc/nginx/http.d/default.conf
elif [[ -f /etc/nginx/sites-enabled/default ]]; then
  export NGINX_CONFIG=/etc/nginx/sites-enabled/default
else
  echo "Can't find NGINX directory"
  exit 1
fi

# Find IP address
if [[ -n "$(command -v ip)" ]]; then
  GETSSL_IP=$(ip address | awk '/10.30.50/ { print $2 }' | awk -F/ '{ print $1 }')
elif [[ -n "$(command -v hostname)" ]]; then
  GETSSL_IP=$(hostname -I | sed -e 's/[[:space:]]*$//')
else
  echo "Cannot find IP address"
  exit 1
fi

export GETSSL_IP

GETSSL_CMD_HOST=$GETSSL_HOST
export GETSSL_CMD_HOST

if [ -z "$STAGING" ] && [ ! -f ${INSTALL_DIR}/pebble.minica.pem ]; then
  wget --quiet --no-clobber https://raw.githubusercontent.com/letsencrypt/pebble/master/test/certs/pebble.minica.pem 2>&1
  CERT_FILE=/etc/ssl/certs/ca-certificates.crt
  if [ ! -f $CERT_FILE ]; then
    CERT_FILE=/etc/pki/tls/certs/ca-bundle.crt
  fi
  cat $CERT_FILE ${INSTALL_DIR}/pebble.minica.pem > ${INSTALL_DIR}/pebble-ca-bundle.crt
fi
