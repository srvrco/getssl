INSTALL_DIR=/root
CODE_DIR=/getssl


setup_environment() {
    # One-off test setup
    if [[ -d ${INSTALL_DIR}/.getssl ]]; then
        rm -r ${INSTALL_DIR}/.getssl
    fi

    curl --silent -X POST -d '{"host":"'"$GETSSL_HOST"'", "addresses":["'"$GETSSL_IP"'"]}' http://10.30.50.3:8055/add-a
    cp ${CODE_DIR}/test/test-config/nginx-ubuntu-no-ssl "${NGINX_CONFIG}"
    /getssl/test/restart-nginx
}


cleanup_environment() {
    curl --silent -X POST -d '{"host":"'"$GETSSL_HOST"'"}' http://10.30.50.3:8055/clear-a
}


init_getssl() {
    # Run initialisation (create account key, etc)
    run ${CODE_DIR}/getssl -c "$GETSSL_HOST"
    assert_success
    [ -d "$INSTALL_DIR/.getssl" ]
}


create_certificate() {
    # Create certificate
    cp "${CODE_DIR}/test/test-config/${CONFIG_FILE}" "${INSTALL_DIR}/.getssl/${GETSSL_HOST}/getssl.cfg"
    # shellcheck disable=SC2086
    run ${CODE_DIR}/getssl $1 "$GETSSL_HOST"
}

# start nginx in background on alpine via supervisord
# shellcheck disable=SC2153 # Ignore GETSSL_OS looks like typo of GETSSL_IP
if [[ -f /usr/bin/supervisord && -f /etc/supervisord.conf ]]; then
    if [[ ! $(pgrep supervisord) ]]; then
        /usr/bin/supervisord -c /etc/supervisord.conf >&3-
    fi
elif [ "$GETSSL_OS" == "centos7" ]; then
    if [ -z "$(pgrep nginx)" ]; then
        nginx >&3-
    fi
fi

# Find NGINX configuration directory for HTTP-01 testing (need to add SSL to config)
if [[ -f /etc/nginx/conf.d/default.conf ]]; then
    export NGINX_CONFIG=/etc/nginx/conf.d/default.conf
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

if [ ! -f ${INSTALL_DIR}/pebble.minica.pem ]; then
    wget --quiet --no-clobber https://raw.githubusercontent.com/letsencrypt/pebble/master/test/certs/pebble.minica.pem 2>&1
    CERT_FILE=/etc/ssl/certs/ca-certificates.crt
    if [ ! -f $CERT_FILE ]; then
        CERT_FILE=/etc/pki/tls/certs/ca-bundle.crt
    fi
    cat $CERT_FILE ${INSTALL_DIR}/pebble.minica.pem > ${INSTALL_DIR}/pebble-ca-bundle.crt
fi
