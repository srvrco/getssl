#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
}


@test "Create dual certificates using HTTP-01 verification" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    check_nginx
    if [ "$OLD_NGINX" = "false" ]; then
        CONFIG_FILE="getssl-http01-dual-rsa-ecdsa.cfg"
    else
        CONFIG_FILE="getssl-http01-dual-rsa-ecdsa-old-nginx.cfg"
    fi

    setup_environment
    init_getssl
    create_certificate
    assert_success
    check_output_for_errors
    check_certificates
    assert [ -e "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/chain.ec.crt" ]
    assert [ -e "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/fullchain.ec.crt" ]
    assert [ -e "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.ec.crt" ]
}


@test "Check renewal test works for dual certificates using HTTP-01" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    check_nginx
    run ${CODE_DIR}/getssl -d $GETSSL_HOST

    if [ "$OLD_NGINX" = "false" ]; then
        assert_line "certificate on server is same as the local cert"
    else
        assert_line --partial "certificate is valid for more than 30 days"
    fi
    assert_success
}


@test "Force renewal of dual certificates using HTTP-01" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    run ${CODE_DIR}/getssl -f $GETSSL_HOST
    assert_success
    check_output_for_errors
}


@test "Create dual certificates using DNS-01 verification" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    check_nginx
    if [ "$OLD_NGINX" = "false" ]; then
        CONFIG_FILE="getssl-dns01-dual-rsa-ecdsa.cfg"
    else
        CONFIG_FILE="getssl-dns01-dual-rsa-ecdsa-old-nginx.cfg"
    fi

    setup_environment
    init_getssl
    create_certificate
    assert_success
    check_output_for_errors
    check_certificates
    assert [ -e "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/chain.ec.crt" ]
    assert [ -e "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/fullchain.ec.crt" ]
    assert [ -e "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.ec.crt" ]
}


@test "Force renewal of dual certificates using DNS-01" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    run ${CODE_DIR}/getssl -f $GETSSL_HOST
    assert_success
    check_output_for_errors
    cleanup_environment
}
