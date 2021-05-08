#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
}


@test "Test behaviour if ACL= line has a space" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    CONFIG_FILE="getssl-http01-bad-acl.cfg"
    setup_environment
    init_getssl
    create_certificate
    assert_failure
}
