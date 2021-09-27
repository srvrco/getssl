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


@test "Check that new creating a new configuration files uses details from existing certificate" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    else
        CONFIG_FILE="getssl-dns01.cfg"
    fi

    # Create and install certificate for wildcard + another domain
    GETSSL_CMD_HOST="*.${GETSSL_HOST}"
    setup_environment
    init_getssl

    echo 'SANS="a.${GETSSL_HOST}"' > ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg

    create_certificate
    assert_success
    check_output_for_errors

    # Delete configuration
    rm -r ${INSTALL_DIR}/.getssl

    # Create configuration
    run ${CODE_DIR}/getssl -U -d -c "${GETSSL_CMD_HOST}"

    # Assert that the newly created configuration contains the additional domain in SANS
    # if this fails then error in tests will be "grep failed" - this means SANS did not hold the expected value
    # eg   SANS="a.centos7.getssl.test"
    grep -q "SANS=\"a.${GETSSL_HOST}\"" ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl.cfg
    assert_success
}
