#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# These are run for every test, not once per file
teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch $BATS_RUN_TMPDIR/failed.skip
}

setup() {
    [ ! -f $BATS_RUN_TMPDIR/failed.skip ] || skip "skipping tests after first failure"
    if [ -z "$STAGING" ]; then
        export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
    fi
}


@test "Create dual certificates (one wildcard) and copy RSA and ECDSA chain and key to two locations" {
    CONFIG_FILE="getssl-dns01.cfg"

    GETSSL_CMD_HOST="*.${GETSSL_HOST}"

    setup_environment
    init_getssl

    cat <<- 'EOF' > ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg
DUAL_RSA_ECDSA="true"
ACCOUNT_KEY_TYPE="prime256v1"
PRIVATE_KEY_ALG="prime256v1"
DOMAIN_KEY_LOCATION="/etc/nginx/pki/private/server.key;/root/a.${GETSSL_HOST}/server.key"
DOMAIN_CHAIN_LOCATION="/etc/nginx/pki/domain-chain.crt;/root/a.${GETSSL_HOST}/domain-chain.crt" # this is the domain cert and CA cert
EOF

    check_nginx
    if [ "$OLD_NGINX" = "false" ]; then
        echo 'RELOAD_CMD="cp /getssl/test/test-config/nginx-ubuntu-dual-certs ${NGINX_CONFIG} && /getssl/test/restart-nginx"' >> ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg
    else
        echo 'CHECK_REMOTE="false"' >> ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg
    fi

    create_certificate
    assert_success
    check_output_for_errors

    if [ "$OLD_NGINX" = "false" ]; then
        assert_line --partial "rsa certificate installed OK on server"
        assert_line --partial "prime256v1 certificate installed OK on server"
    fi

    # Check that the RSA chain and key have been copied to both locations
    assert [ -e "/etc/nginx/pki/domain-chain.crt" ]
    assert [ -e "/root/a.${GETSSL_HOST}/domain-chain.crt" ]
    assert [ -e "/etc/nginx/pki/private/server.key" ]
    assert [ -e "/root/a.${GETSSL_HOST}/server.key" ]

    # Check that the ECDSA chain and key have been copied to both locations
    assert [ -e "/etc/nginx/pki/domain-chain.ec.crt" ]
    assert [ -e "/root/a.${GETSSL_HOST}/domain-chain.ec.crt" ]
    assert [ -e "/etc/nginx/pki/private/server.ec.key" ]
    assert [ -e "/root/a.${GETSSL_HOST}/server.ec.key" ]

    cleanup_environment
}
