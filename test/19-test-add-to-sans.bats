#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    [ ! -f $BATS_RUN_TMPDIR/failed.skip ] || skip "skipping tests after first failure"
}

teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch $BATS_RUN_TMPDIR/failed.skip
}


setup_file() {
    if [ -z "$STAGING" ]; then
        export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
        curl --silent -X POST -d '{"host":"a.'$GETSSL_HOST'", "addresses":["'$GETSSL_IP'"]}' http://10.30.50.3:8055/add-a
    fi
}


teardown_file() {
    if [ -z "$STAGING" ]; then
        curl --silent -X POST -d '{"host":"a.'$GETSSL_HOST'", "addresses":["'$GETSSL_IP'"]}' http://10.30.50.3:8055/clear-a
    fi
}


@test "Create certificate to check can add to SANS" {
    if [ -n "$STAGING" ]; then
        skip "Not trying on staging server yet"
    fi
    CONFIG_FILE="getssl-dns01.cfg"
    setup_environment
    init_getssl

    create_certificate
    assert_success
    check_output_for_errors
}


@test "Check that if the SANS doesn't change, we don't re-create the certificate (single domain)" {
    if [ -n "$STAGING" ]; then
        skip "Not trying on staging server yet"
    fi
    CONFIG_FILE="getssl-dns01.cfg"

    . "${CODE_DIR}/test/test-config/${CONFIG_FILE}"
    CERT=${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt

    create_certificate
    assert_success
    check_output_for_errors

    # As the SANS list didn't change, a new certificate isn't needed
    refute_line --partial "does not match domains requested"
    refute_line --partial "does not have the same domains as the config - re-create-csr"
    refute_line --partial "certificate installed OK on server"
    assert_line --partial 'certificate is valid for more than'

    # Check that the SAN list in the certificate matches the expected value
    SAN_IN_CERT=$(openssl x509 -in "$CERT" -noout -text | grep "DNS:" | sed 's/^ *//g')
    SAN_EXPECTED="DNS:${GETSSL_HOST}"
    if [[ "$SAN_IN_CERT" != "$SAN_EXPECTED" ]]; then
        echo "# SAN_IN_CERT=$SAN_IN_CERT"
        echo "# SAN_EXPECTED=$SAN_EXPECTED"
    fi
    [ "${SAN_IN_CERT}" = "$SAN_EXPECTED" ]
}


@test "Check certificate is recreated if we add a new domain to SANS" {
    if [ -n "$STAGING" ]; then
        skip "Not trying on staging server yet"
    fi
    CONFIG_FILE="getssl-dns01.cfg"

    cat <<- EOF > ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg
SANS="a.${GETSSL_HOST}"
EOF

    . "${CODE_DIR}/test/test-config/${CONFIG_FILE}"
    CERT=${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt

    create_certificate
    assert_success
    check_output_for_errors

    # As the SANS list changed, a new certificate is needed
    assert_line --partial "does not match domains requested"
    assert_line --partial "does not have the same domains as the config - re-create-csr"
    assert_line --partial "certificate installed OK on server"
    refute_line --partial 'certificate is valid for more than'

    # Check that the SAN list in the certificate matches the expected value
    SAN_IN_CERT=$(openssl x509 -in "$CERT" -noout -text | grep "DNS:" | sed 's/^ *//g')
    SAN_EXPECTED="DNS:${GETSSL_HOST}, DNS:a.${GETSSL_HOST}"
    if [[ "$SAN_IN_CERT" != "$SAN_EXPECTED" ]]; then
        echo "# SAN_IN_CERT=$SAN_IN_CERT"
        echo "# SAN_EXPECTED=$SAN_EXPECTED"
    fi
    [ "${SAN_IN_CERT}" = "$SAN_EXPECTED" ]
}


@test "Check that if the SANS doesn't change, we don't re-create the certificate (multiple domains)" {
    if [ -n "$STAGING" ]; then
        skip "Not trying on staging server yet"
    fi
    CONFIG_FILE="getssl-dns01.cfg"

    cat <<- EOF > ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg
SANS="a.${GETSSL_HOST}"
EOF

    . "${CODE_DIR}/test/test-config/${CONFIG_FILE}"
    CERT=${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt

    create_certificate
    assert_success
    check_output_for_errors

    # As the SANS list didn't change, a new certificate isn't needed
    refute_line --partial "does not match domains requested"
    refute_line --partial "does not have the same domains as the config - re-create-csr"
    refute_line --partial "certificate installed OK on server"
    assert_line --partial 'certificate is valid for more than'

    # Check that the SAN list in the certificate matches the expected value
    SAN_IN_CERT=$(openssl x509 -in "$CERT" -noout -text | grep "DNS:" | sed 's/^ *//g')
    SAN_EXPECTED="DNS:${GETSSL_HOST}, DNS:a.${GETSSL_HOST}"
    if [[ "$SAN_IN_CERT" != "$SAN_EXPECTED" ]]; then
        echo "# SAN_IN_CERT=$SAN_IN_CERT"
        echo "# SAN_EXPECTED=$SAN_EXPECTED"
    fi
    [ "${SAN_IN_CERT}" = "$SAN_EXPECTED" ]
}


@test "Check that if the SANS doesn't change, we don't re-create the certificate (reordered domains)" {
    if [ -n "$STAGING" ]; then
        skip "Not trying on staging server yet"
    fi
    CONFIG_FILE="getssl-dns01.cfg"

    cat <<- EOF > ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg
IGNORE_DIRECTORY_DOMAIN="true"
SANS="a.${GETSSL_HOST}, ${GETSSL_HOST}"
EOF

    . "${CODE_DIR}/test/test-config/${CONFIG_FILE}"
    CERT=${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt

    create_certificate
    assert_success
    check_output_for_errors

    # As the SANS list didn't change, a new certificate isn't needed
    refute_line --partial "does not match domains requested"
    refute_line --partial "does not have the same domains as the config - re-create-csr"
    refute_line --partial "certificate installed OK on server"
    assert_line --partial 'certificate is valid for more than'

    # Check that the SAN list in the certificate matches the expected value
    SAN_IN_CERT=$(openssl x509 -in "$CERT" -noout -text | grep "DNS:" | sed 's/^ *//g')
    SAN_EXPECTED="DNS:${GETSSL_HOST}, DNS:a.${GETSSL_HOST}"
    if [[ "$SAN_IN_CERT" != "$SAN_EXPECTED" ]]; then
        echo "# SAN_IN_CERT=$SAN_IN_CERT"
        echo "# SAN_EXPECTED=$SAN_EXPECTED"
    fi
    [ "${SAN_IN_CERT}" = "$SAN_EXPECTED" ]
}
