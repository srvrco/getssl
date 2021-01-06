#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
    CURRENT_VERSION=$(awk -F '"' '$1 == "VERSION=" {print $2}' ${CODE_DIR}/getssl)
    PREVIOUS_VERSION=$(echo ${CURRENT_VERSION} | awk -F. '{ print $1 "." $2-1}')
    run git clone https://github.com/srvrco/getssl.git "$INSTALL_DIR/upgrade-getssl"
}


teardown() {
    rm -r "$INSTALL_DIR/upgrade-getssl"
}


@test "Test that we are told that a newer version is available" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    cd "$INSTALL_DIR/upgrade-getssl"
    git checkout tags/v${PREVIOUS_VERSION}

    CONFIG_FILE="getssl-http01.cfg"
    setup_environment
    init_getssl
    cp "${CODE_DIR}/test/test-config/${CONFIG_FILE}" "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl.cfg"
    run "$INSTALL_DIR/upgrade-getssl/getssl" --check-config ${GETSSL_CMD_HOST}
    assert_success
    #assert_line "Updated getssl from v${PREVIOUS_VERSION} to v${CURRENT_VERSION}"
    assert_line "A more recent version (v${CURRENT_VERSION}) of getssl is available, please update"
    check_output_for_errors
}


@test "Test that we can upgrade to the newer version" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    cd "$INSTALL_DIR/upgrade-getssl"
    git checkout tags/v${PREVIOUS_VERSION}

    CONFIG_FILE="getssl-http01.cfg"
    setup_environment
    init_getssl
    cp "${CODE_DIR}/test/test-config/${CONFIG_FILE}" "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl.cfg"
    run "$INSTALL_DIR/upgrade-getssl/getssl" --check-config --upgrade ${GETSSL_CMD_HOST}
    assert_success
    assert_line "Updated getssl from v${PREVIOUS_VERSION} to v${CURRENT_VERSION}"
    check_output_for_errors
}


@test "Test that we can upgrade to the newer version when invoking as \"bash ./getssl\"" {
    # Note that `bash getssl` will fail if the CWD isn't in the PATH and an upgrade occurs
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    cd "$INSTALL_DIR/upgrade-getssl"
    git checkout tags/v${PREVIOUS_VERSION}

    CONFIG_FILE="getssl-http01.cfg"
    setup_environment
    init_getssl
    cp "${CODE_DIR}/test/test-config/${CONFIG_FILE}" "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl.cfg"
    run bash ./getssl --check-config --upgrade ${GETSSL_CMD_HOST}
    assert_success
    assert_line "Updated getssl from v${PREVIOUS_VERSION} to v${CURRENT_VERSION}"
    check_output_for_errors
}
