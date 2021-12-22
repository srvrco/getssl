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

setup_file() {
    # Fail if not running in docker and /etc/getssl already exists
    TEST_FAILED=0
    if [ -d /etc/getssl  ]; then
        echo "Test failed: /etc/getssl already exists" >&3
        TEST_FAILED=1
        touch $BATS_RUN_TMPDIR/failed.skip
        return 1
    fi
}

teardown_file() {
    # Cleanup after tests
    if [ ${TEST_FAILED} == 0 ] && [ -d /etc/getssl  ]; then
        rm -rf /etc/getssl
    fi
}

@test "Check that config files in /etc/getssl works" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    CONFIG_FILE="getssl-http01.cfg"
    setup_environment

    # Create /etc/getssl/$DOMAIN
    mkdir -p /etc/getssl/${GETSSL_CMD_HOST}

    # Copy the config file to /etc/getssl
    cp "${CODE_DIR}/test/test-config/${CONFIG_FILE}" "/etc/getssl/${GETSSL_CMD_HOST}/getssl.cfg"
    cp "${CODE_DIR}/test/test-config/getssl-etc-template.cfg" "/etc/getssl/getssl.cfg"

    # Run getssl
    run ${CODE_DIR}/getssl -U -d "$GETSSL_CMD_HOST"

    assert_success
    check_output_for_errors
    assert_line --partial 'Verification completed, obtaining certificate.'
    assert_line --partial 'Requesting certificate'
    refute [ -d '$HOME/.getssl' ]
}


@test "Check that --install doesn't call the ACME server" {
    # NOTE that this test depends on the previous test!
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    CONFIG_FILE="getssl-http01.cfg"

    # Run getssl
    run ${CODE_DIR}/getssl -U -d --install "$GETSSL_CMD_HOST"

    assert_success
    check_output_for_errors
    refute_line --partial 'Verification completed, obtaining certificate.'
    refute_line --partial 'Requesting certificate'
    assert_line --partial 'copying domain certificate to'
    assert_line --partial 'copying private key to'
    assert_line --partial 'copying CA certificate to'
}
