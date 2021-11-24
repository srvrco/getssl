#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    [ ! -f $BATS_RUN_TMPDIR/failed.skip ] || skip "skipping tests after first failure"
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
    if [ -f /usr/bin/drill ]; then
        mv /usr/bin/drill /usr/bin/drill.getssl.bak
    fi
    if [ -f /usr/bin/dig ]; then
        chmod -x /usr/bin/dig
    fi
}


teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch $BATS_RUN_TMPDIR/failed.skip
    if [ -f /usr/bin/drill.getssl.bak ]; then
        mv /usr/bin/drill.getssl.bak /usr/bin/drill
    fi
    if [ -f /usr/bin/dig ]; then
        chmod +x /usr/bin/dig
    fi
}


@test "Test that if dig exists but errors HAS_DIG is not set" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    if [ ! -f /usr/bin/dig ]; then
        skip "dig not installed, skipping dig test"
    fi
    CONFIG_FILE="getssl-http01.cfg"
    setup_environment
    init_getssl
    create_certificate
    assert_success
    refute_line --partial "HAS DIG_OR_DRILL=dig"
    check_output_for_errors
}
