#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'

# This is run for every test
setup() {
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
    if [ -f /usr/bin/dig ]; then
        mv /usr/bin/dig /usr/bin/dig.getssl.bak
    fi
}


teardown() {
    if [ -f /usr/bin/dig.getssl.bak ]; then
        mv /usr/bin/dig.getssl.bak /usr/bin/dig
    fi
}


@test "Create new certificate using staging server, nslookup and DuckDNS" {
    if [ -z "$STAGING" ]; then
        skip "Running internal tests, skipping external test"
    fi
    CONFIG_FILE="getssl-staging-dns01.cfg"

    setup_environment
    init_getssl
    create_certificate
    assert_success
    check_output_for_errors "debug"
}


@test "Force renewal of certificate using staging server, nslookup and DuckDNS" {
    if [ -z "$STAGING" ]; then
        skip "Running internal tests, skipping external test"
    fi
    run ${CODE_DIR}/getssl -f $GETSSL_HOST
    assert_success
    check_output_for_errors "debug"
    cleanup_environment
}
