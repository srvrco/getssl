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


@test "Check that trying to create a wildcard certificate using http-01 validation shows an error message" {
    if [ -n "$STAGING" ]; then
        skip "Internal test, no need to test on staging server"
    else
        CONFIG_FILE="getssl-http01.cfg"
    fi

    # Try and create a wildcard certificate using http-01 validation
    GETSSL_CMD_HOST="*.${GETSSL_HOST}"
    setup_environment
    init_getssl

    create_certificate
    assert_failure
    assert_line --partial "cannot use http-01 validation for wildcard domains"
}
