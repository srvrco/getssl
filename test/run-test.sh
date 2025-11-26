#! /usr/bin/env bash

function add-dynu-domain() {
  domain=$1
  curl -X POST "https://api.dynu.com/v2/dns" \
  -H "accept: application/json" \
  -H "API-Key: $DYNU_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "'"${domain}"'",
    "group": "",
    "ipv4Address": "1.2.3.4",
    "ipv6Address": "",
    "ttl": 30,
    "ipv4": true,
    "ipv6": false,
    "ipv4WildcardAlias": false,
    "ipv6WildcardAlias": false
  }'
}

function get-dynu-domain-id() {
  domain=$1
  curl -s -X GET "https://api.dynu.com/v2/dns" \
  -H "accept: application/json" \
  -H "API-Key: $DYNU_API_KEY" | \
  jq -r ".domains[] | select(.name | contains(\"${domain}\")) | .id"
}

function remove-dynu-domain() {
  domain=$1
  echo "Removing dynu domain: $domain"
  domain_id=$(get-dynu-domain-id "$domain")
  echo "Found id for dynu domain: $domain = $domain_id"
  if [ -n "$domain_id" ] && [ "$domain_id" != "null" ]; then
    curl -X DELETE "https://api.dynu.com/v2/dns/${domain_id}" \
    -H "accept: application/json" \
    -H "API-Key: $DYNU_API_KEY"
    echo "Domain $domain removed successfully"
  else
    echo "Domain $domain not found or already removed"
  fi
}

# Cleanup function to remove dynu domains on exit
cleanup() {
  if [[ "$OS" == *"dynu"* ]] && [ -n "$DYNU_API_KEY" ]; then
    echo "Cleaning up dynu domains..."
    remove-dynu-domain "wild-$ALIAS"
    remove-dynu-domain "$ALIAS"
  fi
}

if [ $# -eq 0 ]; then
  echo "Usage: $(basename "$0") <os> [<command>]"
  echo "e.g. $(basename "$0") alpine bats /getssl/test"
  echo "e.g. $(basename "$0") ubuntu 11-mixed-case.bats"
  echo "e.g. $(basename "$0") ubuntu /getssl/test/debug-test.sh -d getssl-http01.cfg"
  exit 1
fi
OS=$1

if [ $# -gt 1 ]; then
  shift
  COMMAND=$*
  if [[ $COMMAND != bash ]] && [[ $COMMAND != /getssl/test/debug-test.sh* ]]; then
    if [[ $COMMAND != "bats /getssl/test"* ]]; then
      if [[ $COMMAND == /getssl/test* ]]; then
        COMMAND="bats $COMMAND"
      elif [[ $COMMAND == test/* ]]; then
        COMMAND="bats /getssl/$COMMAND"
      else
        COMMAND="bats /getssl/test/$COMMAND"
      fi
    fi
    if [[ $COMMAND != *.bats ]]; then
      COMMAND="${COMMAND}.bats"
    fi
  fi
else
  COMMAND="bats /getssl/test --timing"
fi
echo "Running $COMMAND"

REPO=""
if [ -n "$GITHUB_REPOSITORY" ] ; then
  REPO="$(echo "$GITHUB_REPOSITORY" | cut -d/ -f1)"
  if [[ "$REPO" == "srvrco" ]] ; then
    REPO=""
  else
    REPO="${REPO}-"
  fi
fi

ALIAS="$OS.getssl.test"
GETSSL_IDN_HOST="$OS.xn--t-r1a81lydm69gz81r.test"
STAGING=""
GETSSL_OS=$OS

if [[ "$OS" == *"duckdns"* ]]; then
  ALIAS="${REPO}${OS%-duckdns}-getssl.duckdns.org"
  STAGING="--env STAGING=true --env dynamic_dns=duckdns"
  GETSSL_OS="${OS%-duckdns}"
elif [[ "$OS" == *"dynu"* ]]; then
  ALIAS="${REPO}${OS%-dynu}-getssl.freeddns.org"
  STAGING="--env STAGING=true --env dynamic_dns=dynu"
  GETSSL_OS="${OS%-dynu}"
  if [ -n "$DYNU_API_KEY" ]; then
    echo "Creating Dynu domains for $OS..."
    add-dynu-domain "$ALIAS"
    add-dynu-domain "wild-$ALIAS"
  else
    echo "Warning: DYNU_API_KEY not set, skipping domain creation"
  fi
elif [[ "$OS" == *"acmedns"* ]]; then
  ALIAS="${REPO}${OS}-getssl.freeddns.org"
  STAGING="--env STAGING=true --env dynamic_dns=acmedns"
  GETSSL_OS="${OS%-acmedns}"
elif [[ "$OS" == "bash"* ]]; then
  GETSSL_OS="alpine"
fi

if tty -s; then
  INT="-it"
else
  INT=""
fi

docker build --rm -f "test/Dockerfile-$OS" -t "getssl-$OS" .
# shellcheck disable=SC2086
docker run $INT\
  --env GETSSL_HOST=$ALIAS $STAGING \
  --env GETSSL_IDN_HOST=$GETSSL_IDN_HOST \
  --env GETSSL_OS=$GETSSL_OS \
  --env GITHUB_REPOSITORY="${GITHUB_REPOSITORY}" \
  --env DUCKDNS_TOKEN="${DUCKDNS_TOKEN}" \
  --env DYNU_API_KEY="${DYNU_API_KEY}" \
  -v "$(pwd)":/getssl \
  --rm \
  --network ${PWD##*/}_acmenet \
  --network-alias $ALIAS \
  --network-alias $GETSSL_IDN_HOST \
  --network-alias "a.$OS.getssl.test" \
  --network-alias "b.$OS.getssl.test" \
  --network-alias "c.$OS.getssl.test" \
  --network-alias "d.$OS.getssl.test" \
  --network-alias "e.$OS.getssl.test" \
  --network-alias "f.$OS.getssl.test" \
  --network-alias "g.$OS.getssl.test" \
  --network-alias "h.$OS.getssl.test" \
  --network-alias "i.$OS.getssl.test" \
  --network-alias "j.$OS.getssl.test" \
  --network-alias "k.$OS.getssl.test" \
  --network-alias "wild-$OS.getssl.test" \
  --name "getssl-$OS" \
  "getssl-$OS" \
  $COMMAND

# Run cleanup function to delete Dynu domains (otherwise get misused)
cleanup
