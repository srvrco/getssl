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


assert_archived_fullchain() {
    local fullchain_file archive_name archive_file
    fullchain_file="$1"
    archive_name="$2"
    archive_file=$(find "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/archive" -type f -name "$archive_name" -print | head -n 1)
    assert_file_exists "$archive_file"
    assert_files_equal "$fullchain_file" "$archive_file"
}


@test "Use FULL_CHAIN_INCLUDE_ROOT to include the root certificate in the fullchain" {
    CONFIG_FILE="getssl-dns01.cfg"
    setup_environment
    init_getssl

    cat <<- EOF > ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg
FULL_CHAIN_INCLUDE_ROOT="true"
EOF

    create_certificate
    assert_success
    check_output_for_errors
    #assert_archived_fullchain "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/fullchain.crt" "fullchain.crt"

    if [ -n "$STAGING" ]; then
        # https://letsencrypt.org/docs/staging-environment/
        PREFERRED_CHAIN="(STAGING) Pretend Pear X1"
    else
        # pebble doesn't support CA Issuers so the fullchain.crt will just contain the certificate (code path means it won't contain the intermediate cert in this case)
        # This is testing that requesting FULL_CHAIN_INCLUDE_ROOT doesn't fail if there is no CA Issuers in the certificate
        PREFERRED_CHAIN=$(openssl crl2pkcs7 -nocrl -certfile "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt" | openssl pkcs7 -print_certs -text -noout | grep Subject: | tail -1 | awk -F"CN=" '{ print $2 }')
    fi

    final_issuer=$(openssl crl2pkcs7 -nocrl -certfile "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/fullchain.crt" | openssl pkcs7 -print_certs -text -noout | grep Subject: | tail -1 | awk -F"CN=" '{ print $2 }')

    # verify certificate includes the chain root
    if [[ "${PREFERRED_CHAIN}" != "$final_issuer" ]]; then
        echo "# PREFERRED_CHAIN=$PREFERRED_CHAIN"
        echo "# final_issuer=$final_issuer"
    fi
    [ "${PREFERRED_CHAIN}" = "$final_issuer" ]
}


@test "Use FULL_CHAIN_INCLUDE_ROOT with dual certificates" {
    if [ -n "$STAGING" ]; then
        PREFERRED_CHAIN="(STAGING) Doctored Durian Root CA X3"
    fi

    CONFIG_FILE="getssl-dns01.cfg"
    setup_environment
    init_getssl

    cat <<- EOF > ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg
FULL_CHAIN_INCLUDE_ROOT="true"
DUAL_RSA_ECDSA="true"
ACCOUNT_KEY_TYPE="prime256v1"
PRIVATE_KEY_ALG="prime256v1"
CHECK_REMOTE="false"
EOF

    create_certificate
    assert_success
    check_output_for_errors
    check_certificates
    #assert_archived_fullchain "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/fullchain.crt" "fullchain.crt"
    #assert_archived_fullchain "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/fullchain.ec.crt" "fullchain.ec.crt"
    assert_file_exists "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/chain.ec.crt"
    assert_file_exists "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/fullchain.ec.crt"
    assert_file_exists "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.ec.crt"

    if [ -n "$STAGING" ]; then
        PREFERRED_CHAIN="(STAGING) Pretend Pear X1"
    else
        # pebble doesn't support CA Issuers so the fullchain.crt will just contain the certificate (code path means it won't contain the intermediate cert in this case)
        # This is testing that requesting FULL_CHAIN_INCLUDE_ROOT doesn't fail if there is no CA Issuers in the certificate
        PREFERRED_CHAIN=$(openssl crl2pkcs7 -nocrl -certfile "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt" | openssl pkcs7 -print_certs -text -noout | grep Subject: | tail -1 | awk -F"CN=" '{ print $2 }')
    fi

    # verify both rsa and ecdsa certificates include the chain root
    final_issuer=$(openssl crl2pkcs7 -nocrl -certfile "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/fullchain.crt" | openssl pkcs7 -print_certs -text -noout | grep Subject: | tail -1 | awk -F"CN=" '{ print $2 }')
    if [[ "${PREFERRED_CHAIN}" != "$final_issuer" ]]; then
        echo "# PREFERRED_CHAIN=$PREFERRED_CHAIN"
        echo "# final_issuer=$final_issuer"
    fi
    [ "${PREFERRED_CHAIN}" = "$final_issuer" ]
    ecdsa_final_issuer=$(openssl crl2pkcs7 -nocrl -certfile "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/fullchain.ec.crt" | openssl pkcs7 -print_certs -text -noout | grep Subject: | tail -1 | awk -F"CN=" '{ print $2 }')
    if [[ "$PREFERRED_CHAIN" != "$ecdsa_final_issuer" ]]; then
        echo "# PREFERRED_CHAIN=$PREFERRED_CHAIN"
        echo "# ecdsa_final_issuer=$ecdsa_final_issuer"
    fi
    [ "${PREFERRED_CHAIN}" = "$ecdsa_final_issuer" ]
}
