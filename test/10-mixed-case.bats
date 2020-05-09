#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
}

@test "Check that HTTP-01 verification works if the domain is not lowercase" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    CONFIG_FILE="getssl-http01.cfg"
    GETSSL_CMD_HOST=$(echo $GETSSL_HOST | tr a-z A-Z)

    setup_environment
    init_getssl
    create_certificate

    assert_success
    check_output_for_errors
}

@test "Check that DNS-01 verification works if the domain is not lowercase" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    CONFIG_FILE="getssl-dns01.cfg"
    GETSSL_CMD_HOST=$(echo $GETSSL_HOST | tr a-z A-Z)
    setup_environment

    init_getssl
    create_certificate
    assert_success
    check_output_for_errors
}
