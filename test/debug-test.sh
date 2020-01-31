#!/usr/bin/env bash

# This runs getssl outside of the BATS framework for debugging, etc, against pebble
# Usage: /getssl/test/debug-test.sh getssl-http01.cfg

CONFIG_FILE=$1
source /getssl/test/test_helper.bash

setup_environment 3>&1
export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt

"${CODE_DIR}/getssl" -c "$GETSSL_HOST" 3>&1
cp "${CODE_DIR}/test/test-config/${CONFIG_FILE}" "${INSTALL_DIR}/.getssl/${GETSSL_HOST}/getssl.cfg"
"${CODE_DIR}/getssl" -f "$GETSSL_HOST" 3>&1
