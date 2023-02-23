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
    #export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
}


@test "Run getssl without any arguments to verify the usage message is shown" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    run ${CODE_DIR}/getssl
    assert_line --partial "Usage: getssl"
    assert_success
}


@test "Run getssl with --nocheck and verify the usage message is shown" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    run ${CODE_DIR}/getssl --nocheck
    assert_line --partial "Usage: getssl"
    assert_success
}


@test "Run getssl with --upgrade and verify the usage message is NOT shown" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    # Feb-23 Getting semi-repeatable "can't check for upgrades: ''" errors which are because the limit is being exceeded (re-use of github action ip?)
    check_github_quota 7
    run ${CODE_DIR}/getssl --upgrade
    refute_output
    assert_success
}
