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


@test "Check that getssl -c fails with an error message if mktemp fails" {
    if [ -n "$STAGING" ]; then
        skip "Internal test, no need to test on staging server"
    else
        CONFIG_FILE="getssl-http01.cfg"
    fi

    # set TMPDIR to an invalid directory and check for failure
    export TMPDIR=/getssl.invalid.directory
    setup_environment
    run ${CODE_DIR}/getssl -U -d -c "$GETSSL_CMD_HOST"
    assert_failure
    assert_line --partial "mktemp failed"
}


@test "Check that getssl fails with an error message if mktemp fails" {
    if [ -n "$STAGING" ]; then
        skip "Internal test, no need to test on staging server"
    else
        CONFIG_FILE="getssl-http01.cfg"
    fi

    setup_environment
    init_getssl

    # set TMPDIR to an invalid directory and check for failure
    export TMPDIR=/getssl.invalid.directory
    create_certificate
    assert_failure
    assert_line --partial "mktemp failed"
}
