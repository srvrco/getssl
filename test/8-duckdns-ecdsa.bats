#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# These are run for every test, not once per file
setup() {
    if [ -n "$STAGING" ]; then
        export GETSSL_HOST=getssl.duckdns.org
    fi
}


@test "Create new certificate using staging server and prime256v1" {
    if [ -z "$STAGING" ]; then
        skip "Running internal tests, skipping external test"
    fi
    CONFIG_FILE="getssl-duckdns01.cfg"
    GETSSL_HOST=getssl.duckdns.org

    setup_environment
    init_getssl
    sed -e 's/rsa/prime256v1/g' < "${CODE_DIR}/test/test-config/${CONFIG_FILE}" > "${INSTALL_DIR}/.getssl/${GETSSL_HOST}/getssl.cfg"
    run ${CODE_DIR}/getssl -d "$GETSSL_HOST"
    assert_success
    refute_output --regexp '[Ff][Aa][Ii][Ll][Ee][Dd]'
    refute_output --regexp '[^:][Ee][Rr][Rr][Oo][Rr][^:]'
    refute_output --regexp '[Ww][Aa][Rr][Nn][Ii][Nn][Gg]'
}


@test "Force renewal of certificate using staging server and prime256v1" {
    if [ -z "$STAGING" ]; then
        skip "Running internal tests, skipping external test"
    fi
    run ${CODE_DIR}/getssl -d -f $GETSSL_HOST
    assert_success
    refute_output --regexp '[Ff][Aa][Ii][Ll][Ee][Dd]'
    refute_output --regexp '[^:][Ee][Rr][Rr][Oo][Rr][^:]'
    refute_output --regexp '[Ww][Aa][Rr][Nn][Ii][Nn][Gg]'
    cleanup_environment
}


@test "Create new certificate using staging server and secp384r1" {
    if [ -z "$STAGING" ]; then
        skip "Running internal tests, skipping external test"
    fi
    CONFIG_FILE="getssl-duckdns01.cfg"
    GETSSL_HOST=getssl.duckdns.org

    setup_environment
    init_getssl
    sed -e 's/rsa/secp384r1/g' < "${CODE_DIR}/test/test-config/${CONFIG_FILE}" > "${INSTALL_DIR}/.getssl/${GETSSL_HOST}/getssl.cfg"
    run ${CODE_DIR}/getssl -d "$GETSSL_HOST"
    assert_success
    refute_output --regexp '[Ff][Aa][Ii][Ll][Ee][Dd]'
    refute_output --regexp '[^:][Ee][Rr][Rr][Oo][Rr][^:]'
    refute_output --regexp '[Ww][Aa][Rr][Nn][Ii][Nn][Gg]'
}


@test "Force renewal of certificate using staging server and secp384r1" {
    if [ -z "$STAGING" ]; then
        skip "Running internal tests, skipping external test"
    fi
    run ${CODE_DIR}/getssl -d -f $GETSSL_HOST
    assert_success
    refute_output --regexp '[Ff][Aa][Ii][Ll][Ee][Dd]'
    refute_output --regexp '[^:][Ee][Rr][Rr][Oo][Rr][^:]'
    refute_output --regexp '[Ww][Aa][Rr][Nn][Ii][Nn][Gg]'
    cleanup_environment
}


# Note letsencrypt doesn't support ECDSA curve P-521 as it's being deprecated
