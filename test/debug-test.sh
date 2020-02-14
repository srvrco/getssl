#!/usr/bin/env bash

# This runs getssl outside of the BATS framework for debugging, etc, against pebble
# Usage: /getssl/test/debug-test.sh getssl-http01.cfg

DEBUG=""
if [ $# -eq 2 ]; then
    DEBUG=$1
    shift
fi

CONFIG_FILE=$1
if [ ! -e "$CONFIG_FILE" ]; then
    CONFIG_FILE=${CODE_DIR}/test/test-config/${CONFIG_FILE}
fi
source /getssl/test/test_helper.bash

setup_environment 3>&1
export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt

"${CODE_DIR}/getssl" -c "$GETSSL_HOST" 3>&1
cp "${CONFIG_FILE}" "${INSTALL_DIR}/.getssl/${GETSSL_HOST}/getssl.cfg"
# shellcheck disable=SC2086
"${CODE_DIR}/getssl" ${DEBUG} -f "$GETSSL_HOST" 3>&1
