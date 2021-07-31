#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch ${BATS_PARENT_TMPNAME}.skip
}

setup() {
    [ !   -f ${BATS_PARENT_TMPNAME}.skip ] || skip "skip remaining tests"
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
}


@test "Test that running in POSIX mode shows an error" {
    # v2.31 uses read to create an array in the get_auth_dns function which causes a parse error in posix mode
    # Could be re-written to not use this functionality if it causes for required.
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    run bash --posix "${CODE_DIR}/getssl"
    assert_failure
    assert_line "getssl: Running with POSIX mode enabled is not supported"
    check_output_for_errors
}
