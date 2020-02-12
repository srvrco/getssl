#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
}


@test "Create dual certificates using HTTP-01 verification" {
    CONFIG_FILE="getssl-http01-dual-rsa-ecdsa.cfg"
    setup_environment
    init_getssl
    create_certificate
    assert_success
}


@test "Force renewal of dual certificates using HTTP-01" {
    #!FIXME test certificate has been updated
    run ${CODE_DIR}/getssl -f $GETSSL_HOST
    assert_success
}

@test "Create dual certificates using DNS-01 verification" {
    CONFIG_FILE="getssl-dns01-dual-rsa-ecdsa.cfg"
    setup_environment
    init_getssl
    create_certificate
    assert_success
}


@test "Force renewal of dual certificates using DNS-01" {
    #!FIXME test certificate has been updated
    run ${CODE_DIR}/getssl -f $GETSSL_HOST
    assert_success
    cleanup_environment
}
