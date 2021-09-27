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


@test "Use PREFERRED_CHAIN to select an alternate root" {
    if [ -n "$STAGING" ]; then
        PREFERRED_CHAIN="\(STAGING\) Pretend Pear X1"
        CHECK_CHAIN="(STAGING) Pretend Pear X1"
    else
        PREFERRED_CHAIN=$(curl --silent https://pebble:15000/roots/2 | openssl x509 -text -noout | grep "Issuer:" | awk -F"CN *= *" '{ print $2 }')
        PREFERRED_CHAIN="${PREFERRED_CHAIN# }" # remove leading whitespace
        CHECK_CHAIN=$PREFERRED_CHAIN
    fi

    CONFIG_FILE="getssl-dns01.cfg"
    setup_environment
    init_getssl

    cat <<- EOF > ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg
PREFERRED_CHAIN="${PREFERRED_CHAIN}"
EOF

    create_certificate
    assert_success
    check_output_for_errors

    issuer=$(openssl crl2pkcs7 -nocrl -certfile "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/fullchain.crt" | openssl pkcs7 -print_certs -text -noout | grep Issuer: | tail -1 | awk -F"CN=" '{ print $2 }')
    # verify certificate is issued by preferred chain root
    if [[ "${CHECK_CHAIN}" != "$issuer" ]]; then
        echo "# PREFERRED_CHAIN=$PREFERRED_CHAIN"
        echo "# issuer=$issuer"
    fi

    [ "${CHECK_CHAIN}" = "$issuer" ]
}


@test "Use PREFERRED_CHAIN to select the default root" {
    if [ -n "$STAGING" ]; then
        PREFERRED_CHAIN="\(STAGING\) Doctored Durian Root CA X3"
        CHECK_CHAIN="(STAGING) Doctored Durian Root CA X3"
    else
        PREFERRED_CHAIN=$(curl --silent https://pebble:15000/roots/0 | openssl x509 -text -noout | grep Issuer: | awk -F"CN *= *" '{ print $2 }')
        PREFERRED_CHAIN="${PREFERRED_CHAIN# }" # remove leading whitespace
        CHECK_CHAIN=$PREFERRED_CHAIN
    fi

    CONFIG_FILE="getssl-dns01.cfg"
    setup_environment
    init_getssl

    cat <<- EOF > ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg
PREFERRED_CHAIN="${PREFERRED_CHAIN}"
EOF

    create_certificate
    assert_success
    check_output_for_errors

    issuer=$(openssl crl2pkcs7 -nocrl -certfile "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/fullchain.crt" | openssl pkcs7 -print_certs -text -noout | grep Issuer: | tail -1 | awk -F"CN=" '{ print $2 }')
    # verify certificate is issued by preferred chain root
    if [[ "${CHECK_CHAIN}" != "$issuer" ]]; then
        echo "# PREFERRED_CHAIN=$PREFERRED_CHAIN"
        echo "# issuer=$issuer"
    fi
    [ "${CHECK_CHAIN}" = "$issuer" ]
}


@test "Use PREFERRED_CHAIN to select an alternate root by suffix" {
    if [ -n "$STAGING" ]; then
        FULL_PREFERRED_CHAIN="(STAGING) Pretend Pear X1"
    else
        FULL_PREFERRED_CHAIN=$(curl --silent https://pebble:15000/roots/2 | openssl x509 -text -noout | grep "Issuer:" | awk -F"CN *= *" '{ print $2 }')
        FULL_PREFERRED_CHAIN="${FULL_PREFERRED_CHAIN# }" # remove leading whitespace
    fi

    # Take the last word from FULL_PREFERRED_CHAIN as the chain to use
    PREFERRED_CHAIN="${FULL_PREFERRED_CHAIN##* }"
    CONFIG_FILE="getssl-dns01.cfg"
    setup_environment
    init_getssl

    cat <<- EOF > ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg
PREFERRED_CHAIN="${PREFERRED_CHAIN}"
EOF

    create_certificate
    assert_success
    check_output_for_errors

    issuer=$(openssl crl2pkcs7 -nocrl -certfile "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/fullchain.crt" | openssl pkcs7 -print_certs -text -noout | grep Issuer: | tail -1 | awk -F"CN=" '{ print $2 }')
    # verify certificate is issued by preferred chain root
    if [[ "${FULL_PREFERRED_CHAIN}" != "$issuer" ]]; then
        echo "# PREFERRED_CHAIN=$PREFERRED_CHAIN"
        echo "# FULL_PREFERRED_CHAIN=$FULL_PREFERRED_CHAIN"
        echo "# issuer=$issuer"
    fi
    [ "${FULL_PREFERRED_CHAIN}" = "$issuer" ]
}
