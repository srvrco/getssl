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


@test "Check for globbing for wildcard domains" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    else
        CONFIG_FILE="getssl-dns01.cfg"
    fi

    GETSSL_CMD_HOST="*.${GETSSL_HOST}"
    setup_environment

    init_getssl

    # Create a directory in /root which looks like a domain so that if glob expansion is performed a certificate for the wrong domain will be created
    mkdir -p "${INSTALL_DIR}/a.${GETSSL_HOST}"

    create_certificate
    assert_success
    check_output_for_errors
}


@test "Force renewal of wildcard certificate" {
    if [ -n "$STAGING" ]; then
        skip "Not trying on staging server yet"
    fi

    run ${CODE_DIR}/getssl -U -d -f "*.$GETSSL_HOST"
    assert_success
    refute_line --partial "certificate is valid for more than"
    check_output_for_errors
}
