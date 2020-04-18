#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
}

@test "Check that config files in /etc/getssl works" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    CONFIG_FILE="getssl-http01.cfg"
    setup_environment

    # Create /etc/getssl/$DOMAIN
    rm -rf /etc/getssl
    mkdir -p /etc/getssl/${GETSSL_CMD_HOST}

    # Copy the config file to /etc/getssl
    cp "${CODE_DIR}/test/test-config/${CONFIG_FILE}" "/etc/getssl/${GETSSL_CMD_HOST}/getssl.cfg"
    cp "${CODE_DIR}/test/test-config/getssl-etc-template.cfg" "/etc/getssl/getssl.cfg"

    # Run getssl
    run ${CODE_DIR}/getssl "$GETSSL_CMD_HOST"

    assert_success
    refute_output --regexp '[Ff][Aa][Ii][Ll][Ee][Dd]'
    refute_output --regexp '[Ee][Rr][Rr][Oo][Rr]'
    refute_output --regexp '[Ww][Aa][Rr][Nn][Ii][Nn][Gg]'
    assert_line 'Verification completed, obtaining certificate.'
    assert_line 'Requesting certificate'
    refute [ -d '$HOME/.getssl' ]
}


@test "Check that --install doesn't call the ACME server" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    CONFIG_FILE="getssl-http01.cfg"
    #setup_environment

    # Create /etc/getssl/$DOMAIN
    #mkdir -p /etc/getssl/${GETSSL_CMD_HOST}

    # Copy the config file to /etc/getssl
    #cp "${CODE_DIR}/test/test-config/${CONFIG_FILE}" "/etc/getssl/${GETSSL_CMD_HOST}/getssl.cfg"
    #cp "${CODE_DIR}/test/test-config/getssl-etc-template.cfg" "/etc/getssl/getssl.cfg"

    # Run getssl
    run ${CODE_DIR}/getssl --install "$GETSSL_CMD_HOST"

    assert_success
    refute_output --regexp '[Ff][Aa][Ii][Ll][Ee][Dd]'
    refute_output --regexp '[Ee][Rr][Rr][Oo][Rr]'
    refute_output --regexp '[Ww][Aa][Rr][Nn][Ii][Nn][Gg]'
    refute_line 'Verification completed, obtaining certificate.'
    refute_line 'Requesting certificate'
    assert_line --partial 'copying domain certificate to'
    assert_line --partial 'copying private key to'
    assert_line --partial 'copying CA certificate to'
}
