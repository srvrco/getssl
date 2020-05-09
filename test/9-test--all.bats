#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
    export PATH=$PATH:/getssl
}


@test "Create new certificate using --all" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    # Setup
    CONFIG_FILE="getssl-http01.cfg"
    setup_environment
    init_getssl
    cp "${CODE_DIR}/test/test-config/${CONFIG_FILE}" "${INSTALL_DIR}/.getssl/${GETSSL_HOST}/getssl.cfg"

    # Run test
    run ${CODE_DIR}/getssl --all

    # Check success conditions
    assert_success
    check_output_for_errors
}
