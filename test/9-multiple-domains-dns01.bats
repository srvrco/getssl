#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
}


@test "Create certificates for multi-level domains using DNS-01 verification" {
    # This tests we can create a certificate for <os>.getssl.test and getssl.test (in SANS)
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    CONFIG_FILE="getssl-multiple-domains-dns01.cfg"
    setup_environment

    # Add top level domain from SANS to DNS
    curl --silent -X POST -d '{"host":"getssl.test", "addresses":["'$GETSSL_IP'"]}' http://10.30.50.3:8055/add-a

    init_getssl
    create_certificate
    assert_success
    check_output_for_errors
}


@test "Force renewal of multi-level domains using DNS-01" {
    # This tests we can renew a certificate for <os>.getssl.test and getssl.test (in SANS)
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    run ${CODE_DIR}/getssl -f $GETSSL_HOST
    assert_success
    check_output_for_errors
    # Remove all the dns aliases
    cleanup_environment
    curl --silent -X POST -d '{"host":"getssl.tst"}' http://10.30.50.3:8055/clear-a
}

@test "Test IGNORE_DIRECTORY_DOMAIN using DNS-01 verification" {
    # This tests we can create a certificate for getssl.test and <os>.getssl.test (*both* in SANS)
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    CONFIG_FILE="getssl-ignore-directory-domain.cfg"
    setup_environment

    # Add top level domain from SANS to DNS
    curl --silent -X POST -d '{"host":"getssl.test", "addresses":["'$GETSSL_IP'"]}' http://10.30.50.3:8055/add-a

    init_getssl
    create_certificate
    assert_success
    check_output_for_errors
}
