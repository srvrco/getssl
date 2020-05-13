#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


@test "Check that auto upgrade to v2 doesn't change pebble url" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    CONFIG_FILE="getssl-upgrade-test-pebble.cfg"
    setup_environment
    mkdir ${INSTALL_DIR}/.getssl
    cp "${CODE_DIR}/test/test-config/${CONFIG_FILE}" "${INSTALL_DIR}/.getssl/getssl.cfg"
    run ${CODE_DIR}/getssl -d --check-config "$GETSSL_CMD_HOST"
    assert_success
    assert_line 'Using certificate issuer: https://pebble:14000/dir'
}


@test "Check that auto upgrade to v2 doesn't change v2 staging url" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    CONFIG_FILE="getssl-upgrade-test-v2-staging.cfg"
    setup_environment
    mkdir ${INSTALL_DIR}/.getssl
    cp "${CODE_DIR}/test/test-config/${CONFIG_FILE}" "${INSTALL_DIR}/.getssl/getssl.cfg"
    run ${CODE_DIR}/getssl -d --check-config "$GETSSL_CMD_HOST"
    assert_success
    assert_line 'Using certificate issuer: https://acme-staging-v02.api.letsencrypt.org/directory'
}


@test "Check that auto upgrade to v2 doesn't change v2 prod url" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    CONFIG_FILE="getssl-upgrade-test-v2-prod.cfg"
    setup_environment
    mkdir ${INSTALL_DIR}/.getssl
    cp "${CODE_DIR}/test/test-config/${CONFIG_FILE}" "${INSTALL_DIR}/.getssl/getssl.cfg"
    run ${CODE_DIR}/getssl -d --check-config "$GETSSL_CMD_HOST"
    assert_success
    assert_line 'Using certificate issuer: https://acme-v02.api.letsencrypt.org/directory'
}


@test "Check that auto upgrade to v2 changes v1 staging to v2 staging url" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    CONFIG_FILE="getssl-upgrade-test-v1-staging.cfg"
    setup_environment
    mkdir ${INSTALL_DIR}/.getssl
    cp "${CODE_DIR}/test/test-config/${CONFIG_FILE}" "${INSTALL_DIR}/.getssl/getssl.cfg"
    run ${CODE_DIR}/getssl -d --check-config "$GETSSL_CMD_HOST"
    assert_success
    assert_line 'Using certificate issuer: https://acme-staging-v02.api.letsencrypt.org/directory'
}


@test "Check that auto upgrade to v2 changes v1 prod to v2 prod url" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    CONFIG_FILE="getssl-upgrade-test-v1-prod.cfg"
    setup_environment
    mkdir ${INSTALL_DIR}/.getssl
    cp "${CODE_DIR}/test/test-config/${CONFIG_FILE}" "${INSTALL_DIR}/.getssl/getssl.cfg"
    run ${CODE_DIR}/getssl -d --check-config "$GETSSL_CMD_HOST"
    assert_success
    assert_line 'Using certificate issuer: https://acme-v02.api.letsencrypt.org/directory'
}
