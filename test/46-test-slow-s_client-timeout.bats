#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


setup_file() {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    # Create a mock openssl that intercepts s_client calls to simulate a hung
    # connection. The real openssl s_client has no default connect timeout, so
    # connecting to a firewalled host can hang for ~2 minutes.
    # This mock simulates that by sleeping when s_client is called.
    # Reproduces issue #283 (https://github.com/srvrco/getssl/issues/283)
    cat << 'MOCK_OPENSSL' > /getssl/test/openssl
#!/usr/bin/env bash
# Mock openssl: intercept s_client calls to simulate a hung connection.
if [[ "$1" == "s_client" ]]; then
    sleep 60
    exit 1
fi
# Strip our own directory from PATH before finding real openssl
export PATH="${PATH#/getssl/test:}"
REAL_OPENSSL=$(command -v openssl)
exec "$REAL_OPENSSL" "$@"
MOCK_OPENSSL
   chmod +x /getssl/test/openssl
}


teardown_file() {
    # Clean up mock openssl
    if [ -e /getssl/test/openssl ]; then
        rm /getssl/test/openssl
    fi
}


# This is run for every test
setup() {
    [ ! -f $BATS_RUN_TMPDIR/failed.skip ] || skip "skipping tests after first failure"
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
}


# This is run for every test
teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch $BATS_RUN_TMPDIR/failed.skip
}


@test "Check that creating a domain config for a host with no port 443 does not hang" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    # Run getssl -c with a timeout to prevent the test itself from hanging.
    # timeout returns 124 if the command times out.
    run timeout -s TERM 10 ${CODE_DIR}/getssl -d -c "$GETSSL_CMD_HOST"

    # The test should NOT time out (exit code 124 means timeout).
    # Without the the "timeout 5" prefixing calls to "openssl s_client" the 
    # mock will sleeps 60s and the openssl mock will return status 124.
    # With the timeout prefix, getssl gets the timeout and the test passes
    refute [ "$status" -eq 124 ]

    # The command should succeed (exit code 0)
    assert_success

    # Check that the domain config was created
    assert [ -s "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl.cfg" ]
}

