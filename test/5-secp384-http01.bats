#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
}


@test "Create new secp384r1 certificate using HTTP-01 verification" {
    CONFIG_FILE="getssl-http01-secp384.cfg"
    setup_environment
    init_getssl
    create_certificate
    assert_success
}


@test "Force renewal of secp384r1 certificate using HTTP-01" {
    run ${CODE_DIR}/getssl -f $GETSSL_HOST
    assert_success
}


@test "Create new secp521r1 certificate using HTTP-01 verification" {
    CONFIG_FILE="getssl-http01-secp521.cfg"
    setup_environment
    init_getssl
    create_certificate
    assert_success
}


@test "Force renewal of secp521r1 certificate using HTTP-01" {
    run ${CODE_DIR}/getssl -f $GETSSL_HOST
    assert_success
}
