#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
}


@test "Create certificate to check revoke" {
    if [ -n "$STAGING" ]; then
        CONFIG_FILE="getssl-staging-dns01-no-suffix.cfg"
    else
        CONFIG_FILE="getssl-http01-no-suffix.cfg"
    fi
    . "${CODE_DIR}/test/test-config/${CONFIG_FILE}"
    setup_environment
    init_getssl
    create_certificate
    assert_success
    check_output_for_errors
}


@test "Check we can revoke a certificate" {
    if [ -n "$STAGING" ]; then
        CONFIG_FILE="getssl-staging-dns01.cfg"
    else
        CONFIG_FILE="getssl-http01.cfg"
    fi
    . "${CODE_DIR}/test/test-config/${CONFIG_FILE}"
    CERT=${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt
    KEY=${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.key

    run ${CODE_DIR}/getssl -d --revoke $CERT $KEY $CA
    assert_success
    check_output_for_errors
}
