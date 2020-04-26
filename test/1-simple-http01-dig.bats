#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
    if [ -f /usr/bin/host ]; then
        mv /usr/bin/host /usr/bin/host.getssl.bak
    fi
    if [ -f /usr/bin/nslookup ]; then
        mv /usr/bin/nslookup /usr/bin/nslookup.getssl.bak
    fi
}


teardown() {
    if [ -f /usr/bin/host.getssl.bak ]; then
        mv /usr/bin/host.getssl.bak /usr/bin/host
    fi
    if [ -f /usr/bin/nslookup.getssl.bak ]; then
        mv /usr/bin/nslookup.getssl.bak /usr/bin/nslookup
    fi
}


@test "Create new certificate using HTTP-01 verification (dig)" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    CONFIG_FILE="getssl-http01.cfg"
    setup_environment
    init_getssl
    create_certificate
    assert_success
    check_output_for_errors
}
