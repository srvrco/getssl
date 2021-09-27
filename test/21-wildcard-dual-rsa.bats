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
    if [ -z "$STAGING" ]; then
        export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
    fi
}


@test "Create secp384r1 wildcard certificate" {
    CONFIG_FILE="getssl-dns01.cfg"

    GETSSL_CMD_HOST="*.${GETSSL_HOST}"

    setup_environment
    init_getssl

    cat <<- EOF > ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg
ACCOUNT_KEY_TYPE="secp384r1"
PRIVATE_KEY_ALG="secp384r1"
EOF

    create_certificate
    assert_success
    check_output_for_errors
    run openssl x509 -noout -text -in "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt"
    assert_line --partial "Public Key Algorithm: id-ecPublicKey"
    cleanup_environment
}


@test "Create dual certificates using DNS-01 verification" {
    CONFIG_FILE="getssl-dns01.cfg"

    GETSSL_CMD_HOST="*.${GETSSL_HOST}"

    setup_environment
    init_getssl

    cat <<- EOF > ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg
DUAL_RSA_ECDSA="true"
ACCOUNT_KEY_TYPE="prime256v1"
PRIVATE_KEY_ALG="prime256v1"
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
    check_certificates
    assert [ -e "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/chain.ec.crt" ]
    assert [ -e "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/fullchain.ec.crt" ]
    assert [ -e "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.ec.crt" ]

    run openssl x509 -noout -text -in "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt"
    assert_line --partial "Public Key Algorithm: rsaEncryption"

    run openssl x509 -noout -text -in "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.ec.crt"
    assert_line --partial "Public Key Algorithm: id-ecPublicKey"

    cleanup_environment
}
