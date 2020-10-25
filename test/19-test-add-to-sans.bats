#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
    curl --silent -X POST -d '{"host":"a.'$GETSSL_HOST'", "addresses":["'$GETSSL_IP'"]}' http://10.30.50.3:8055/add-a
    curl --silent -X POST -d '{"host":"b.'$GETSSL_HOST'", "addresses":["'$GETSSL_IP'"]}' http://10.30.50.3:8055/add-a
}

teardown() {
    curl --silent -X POST -d '{"host":"a.'$GETSSL_HOST'", "addresses":["'$GETSSL_IP'"]}' http://10.30.50.3:8055/clear-a
    curl --silent -X POST -d '{"host":"b.'$GETSSL_HOST'", "addresses":["'$GETSSL_IP'"]}' http://10.30.50.3:8055/clear-a
}



@test "Create certificate to check can add to SANS" {
    skip "FIXME: Certificate is not recreated when SANS is updated"
    if [ -n "$STAGING" ]; then
        skip "Not trying on staging server yet"
        CONFIG_FILE="getssl-staging-dns01.cfg"
    else
        CONFIG_FILE="getssl-dns01-add-to-sans-1.cfg"
    fi
    . "${CODE_DIR}/test/test-config/${CONFIG_FILE}"
    setup_environment


    init_getssl
    create_certificate
    assert_success
    check_output_for_errors
}


@test "Check we can add a new domain to SANS" {
    skip "FIXME: Certificate is not recreated when SANS is updated"
    if [ -n "$STAGING" ]; then
        skip "Not trying on staging server yet"
        CONFIG_FILE="getssl-staging-dns01.cfg"
    else
        CONFIG_FILE="getssl-dns01-add-to-sans-2.cfg"
    fi
    # . "${CODE_DIR}/test/test-config/${CONFIG_FILE}"
    # CERT=${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt
    # KEY=${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.key
    # cp "${CODE_DIR}/test/test-config/${CONFIG_FILE}" "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl.cfg"

    create_certificate
    assert_success
    check_output_for_errors

    # As the SANS list changed, a new certificate is needed
    assert_line --partial "certificate installed OK on server"
    refute_line --partial 'certificate is valid for more than'
}
