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
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
}

teardown_file() {
    cleanup_environment
}

@test "Create new certificate to create a private key" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    CONFIG_FILE="getssl-http01.cfg"
    setup_environment
    init_getssl
    create_certificate
    assert_success
    check_output_for_errors
    # save a coy of the private key
    cp "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.key" "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.key.orig"
}

@test "Renew certificate (not force) and check nothing happens and key doesn't change" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    ORIG_KEY_HASH="$(cat ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.key | sha256sum)"

    run ${CODE_DIR}/getssl -U -d $GETSSL_HOST
    assert_success
    assert_line --partial "certificate is valid for more than 30 days"
    check_output_for_errors

    NEW_KEY_HASH="$(cat ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.key  | sha256sum)"

    assert [ "$NEW_KEY_HASH" == "$ORIG_KEY_HASH" ]
}

@test "Force renewal and check key hasn't changed" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    ORIG_KEY_HASH="$(cat ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.key | sha256sum)"

    run ${CODE_DIR}/getssl -U -d -f $GETSSL_HOST
    assert_success
    check_output_for_errors

    NEW_KEY_HASH="$(cat ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.key  | sha256sum)"

    assert [ "$NEW_KEY_HASH" == "$ORIG_KEY_HASH" ]
}

@test "Change key algorithm, force renewal, and check key has changed" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    ORIG_KEY_HASH="$(cat ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.key | sha256sum)"

    cat <<- 'EOF' > ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg
PRIVATE_KEY_ALG="prime256v1"
EOF

    run ${CODE_DIR}/getssl -U -d $GETSSL_HOST
    assert_success
    refute_line --partial "certificate is valid for more than 30 days"

    check_output_for_errors

    NEW_KEY_HASH="$(cat ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.key  | sha256sum)"

    assert [ "$NEW_KEY_HASH" != "$ORIG_KEY_HASH" ]
}
