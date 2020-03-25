#!/usr/bin/env bash

# This runs getssl outside of the BATS framework for debugging, etc, against pebble
# Usage: /getssl/test/debug-test.sh getssl-http01.cfg

DEBUG=""
if [ $# -eq 2 ]; then
    DEBUG=$1
    shift
fi

#shellcheck disable=SC1091
source /getssl/test/test_helper.bash 3>&1

CONFIG_FILE=$1
if [ ! -e "$CONFIG_FILE" ]; then
    CONFIG_FILE=${CODE_DIR}/test/test-config/${CONFIG_FILE}
fi

setup_environment 3>&1

# Only add the pebble CA to the cert bundle if using pebble
if grep -q pebble "${CONFIG_FILE}"; then
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
fi

"${CODE_DIR}/getssl" -c "$GETSSL_HOST" 3>&1
cp "${CONFIG_FILE}" "${INSTALL_DIR}/.getssl/${GETSSL_HOST}/getssl.cfg"
# shellcheck disable=SC2086
"${CODE_DIR}/getssl" ${DEBUG} -f "$GETSSL_HOST" 3>&1
