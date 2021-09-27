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
        curl --silent -X POST -d '{"host":"b.'$GETSSL_HOST'", "addresses":["'$GETSSL_IP'"]}' http://10.30.50.3:8055/add-a
    fi
}


teardown_file() {
    if [ -z "$STAGING" ]; then
        curl --silent -X POST -d '{"host":"a.'$GETSSL_HOST'", "addresses":["'$GETSSL_IP'"]}' http://10.30.50.3:8055/clear-a
        curl --silent -X POST -d '{"host":"b.'$GETSSL_HOST'", "addresses":["'$GETSSL_IP'"]}' http://10.30.50.3:8055/clear-a
    fi
}


@test "Create certificate to check renewal" {
    if [ -n "$STAGING" ]; then
        skip "Not testing renewal on staging server"
    fi
    CONFIG_FILE="getssl-dns01.cfg"
    setup_environment
    init_getssl

    create_certificate
    assert_success
    check_output_for_errors
}


@test "Check that trying to renew a certificate which doesn't need renewing doesn't do anything" {
    if [ -n "$STAGING" ]; then
        skip "Not trying on staging server yet"
    fi

    CONFIG_FILE="getssl-dns01.cfg"
    . "${CODE_DIR}/test/test-config/${CONFIG_FILE}"
    CERT=${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt
    ORIGINAL_ENDDATE=$(openssl x509 -in "$CERT" -noout -enddate 2>/dev/null| cut -d= -f 2-)

    create_certificate
    assert_success
    check_output_for_errors

    # Check that getssl didn't renew the certificate
    refute_line --partial "certificate needs renewal"
    assert_line --partial 'certificate is valid for more than'

    # Check that the end date in the certificate hasn't changed
    UPDATED_ENDDATE=$(openssl x509 -in "$CERT" -noout -enddate 2>/dev/null| cut -d= -f 2-)
    if [[ "$ORIGINAL_ENDDATE" != "$UPDATED_ENDDATE" ]]; then
        echo "# ORIGINAL_ENDDATE=$ORIGINAL_ENDDATE"
        echo "# UPDATED_ENDDATE =$UPDATED_ENDDATE"
    fi
    [[ "$ORIGINAL_ENDDATE" = "$UPDATED_ENDDATE" ]]
}



@test "Check that we can renew a certificate which does need renewing" {
    if [ -n "$STAGING" ]; then
        skip "Not trying on staging server yet"
    fi

    CONFIG_FILE="getssl-dns01.cfg"
    cat <<- EOF > ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg
RENEW_ALLOW=2000
EOF

    . "${CODE_DIR}/test/test-config/${CONFIG_FILE}"
    CERT=${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt
    ORIGINAL_ENDDATE=$(openssl x509 -in "$CERT" -noout -enddate 2>/dev/null| cut -d= -f 2-)

    create_certificate
    assert_success
    check_output_for_errors

    # Check that getssl didn't renew the certificate
    refute_line --partial 'certificate is valid for more than'

    # Check that the end date in the certificate hasn't changed
    UPDATED_ENDDATE=$(openssl x509 -in "$CERT" -noout -enddate 2>/dev/null| cut -d= -f 2-)
    if [[ "$ORIGINAL_ENDDATE" = "$UPDATED_ENDDATE" ]]; then
        echo "# ORIGINAL_ENDDATE=$ORIGINAL_ENDDATE"
        echo "# UPDATED_ENDDATE =$UPDATED_ENDDATE"
    fi
    [[ "$ORIGINAL_ENDDATE" != "$UPDATED_ENDDATE" ]]
}
