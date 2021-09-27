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
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
}


@test "Test that running in POSIX mode shows an error" {
    # v2.31 uses read to create an array in the get_auth_dns function which causes a parse error in posix mode
    # Could be re-written to not use this functionality if it causes for required.
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    run bash --posix "${CODE_DIR}/getssl" -U -d
    assert_failure
    assert_line --partial "getssl: Running with POSIX mode enabled is not supported"
    check_output_for_errors
}
