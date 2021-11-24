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


@test "Create wildcard certificate" {
    CONFIG_FILE="getssl-dns01.cfg"

    GETSSL_CMD_HOST="*.${GETSSL_HOST}"
    setup_environment
    init_getssl
    create_certificate
    assert_success
    check_output_for_errors
}


@test "Check CHECK_REMOTE works for wildcard certificates" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    run ${CODE_DIR}/getssl -U -d "*.$GETSSL_HOST"
    assert_success
    assert_line --partial "certificate is valid for more than"
    check_output_for_errors
}


@test "Force renewal of wildcard certificate" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    run ${CODE_DIR}/getssl -U -d -f "*.$GETSSL_HOST"
    assert_success
    refute_line --partial "certificate is valid for more than"
    check_output_for_errors
}


@test "Check renewal of near-expiration wildcard certificate" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    echo "RENEW_ALLOW=2000" >> "${INSTALL_DIR}/.getssl/*.${GETSSL_HOST}/getssl.cfg"

    run ${CODE_DIR}/getssl -U -d "*.$GETSSL_HOST"
    assert_success
    refute_line --partial "certificate is valid for more than"
    check_output_for_errors
    cleanup_environment
}
