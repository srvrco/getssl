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


@test "Check can create certificate for wildcard domain using --all" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    else
        CONFIG_FILE="getssl-dns01.cfg"
    fi

    GETSSL_CMD_HOST="*.${GETSSL_HOST}"
    setup_environment
    # Create .getssl directory and .getssl/*.{host} directory
    init_getssl
    cp "${CODE_DIR}/test/test-config/${CONFIG_FILE}" "${INSTALL_DIR}/.getssl/*.${GETSSL_HOST}/getssl.cfg"

    # create another domain in the .getssl directory
    run ${CODE_DIR}/getssl -U -d -c "a.${GETSSL_HOST}"
    cp "${CODE_DIR}/test/test-config/${CONFIG_FILE}" "${INSTALL_DIR}/.getssl/a.${GETSSL_HOST}/getssl.cfg"

    # Create a directory in /root which looks like a domain so that if glob expansion is performed the wildcard certificate won't be created
    mkdir -p "${INSTALL_DIR}/a.${GETSSL_HOST}"

    run ${CODE_DIR}/getssl -U -d --all

    assert_success
    assert_line --partial "Certificate saved in /root/.getssl/*.${GETSSL_HOST}/*.${GETSSL_HOST}"
    assert_line --partial "Certificate saved in /root/.getssl/a.${GETSSL_HOST}/a.${GETSSL_HOST}"
    check_output_for_errors
}
