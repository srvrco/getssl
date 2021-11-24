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
        curl --silent -X POST -d '{"host":"wild-'$GETSSL_HOST'", "addresses":["'$GETSSL_IP'"]}' http://10.30.50.3:8055/add-a
    fi
}


teardown_file() {
    if [ -z "$STAGING" ]; then
        curl --silent -X POST -d '{"host":"wild-'$GETSSL_HOST'", "addresses":["'$GETSSL_IP'"]}' http://10.30.50.3:8055/clear-a
    fi
}


@test "Check can create certificate for wildcard domain as arg and non-wildcard in SANS" {
    CONFIG_FILE="getssl-dns01.cfg"

    # Staging server generates an error if try to create a certificate for *.domain and a.domain
    # so create for *.wild-domain and a.domain instead
    GETSSL_CMD_HOST="*.wild-${GETSSL_HOST}"
    setup_environment
    init_getssl

    echo 'SANS="${GETSSL_HOST}"' > ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg
    if [ -n "$STAGING" ]; then
        echo 'CHECK_REMOTE="false"' >> ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg
    fi

    create_certificate
    assert_success
    check_output_for_errors
    run openssl x509 -noout -text -in "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt"
    # verify certificate is for wildcard domain with non-wildcard domain in the Subject Alternative Name list
    assert_output --regexp "Subject: CN[ ]?=[ ]?\*.wild-${GETSSL_HOST}"
    assert_output --partial "DNS:${GETSSL_HOST}"
}


@test "Check can create certificate for non-wildcard domain as arg and wildcard in SANS" {
    CONFIG_FILE="getssl-dns01.cfg"

    GETSSL_CMD_HOST="${GETSSL_HOST}"
    setup_environment
    init_getssl

    echo 'SANS="*.wild-${GETSSL_HOST}"' > ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg

    create_certificate
    assert_success
    check_output_for_errors
    run openssl x509 -noout -text -in "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt"
    # verify certificate is for non-wildcard domain with wildcard domain in the Subject Alternative Name list
    assert_output --regexp "Subject: CN[ ]?=[ ]?${GETSSL_HOST}"
    assert_output --partial "DNS:*.wild-${GETSSL_HOST}"
}
