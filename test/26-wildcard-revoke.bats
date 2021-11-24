#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch $BATS_RUN_TMPDIR/failed.skip
}

setup() {
    [ ! -f $BATS_RUN_TMPDIR/failed.skip ] || skip "skipping tests after first failure"
    if [ -z "$STAGING" ]; then
        export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
    fi
}


@test "Create certificate to check wildcard revoke" {
    CONFIG_FILE="getssl-dns01.cfg"

    GETSSL_CMD_HOST="*.${GETSSL_HOST}"
    setup_environment
    init_getssl
    create_certificate
    assert_success
    check_output_for_errors
}


@test "Check we can revoke a wildcard certificate" {
    CONFIG_FILE="getssl-dns01.cfg"
    . "${CODE_DIR}/test/test-config/${CONFIG_FILE}"

    GETSSL_CMD_HOST="*.${GETSSL_HOST}"

    CERT=${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt
    KEY=${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.key

    run ${CODE_DIR}/getssl -U -d --revoke $CERT $KEY $CA
    assert_line --partial "certificate revoked"
    assert_success
    check_output_for_errors
}
