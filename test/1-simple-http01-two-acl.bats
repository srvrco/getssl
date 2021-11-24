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


@test "Check that can install challenge token to multiple locations when using HTTP-01 verification" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    CONFIG_FILE="getssl-http01-two-acl.cfg"
    setup_environment
    init_getssl
    create_certificate
    assert_success
    assert_output --partial "to /var/www/html/.well-known/acme-challenge"
    assert_output --partial "to /var/webroot/html/.well-known/acme-challenge"
    check_output_for_errors
}
