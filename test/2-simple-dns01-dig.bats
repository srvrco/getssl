#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
}


@test "Create new certificate using DNS-01 verification (dig)" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    CONFIG_FILE="getssl-dns01.cfg"
    setup_environment
    init_getssl
    create_certificate -d
    assert_success
    assert_output --partial "dig"
    refute_output --regexp '[Ff][Aa][Ii][Ll][Ee][Dd]'
    refute_output --regexp '[^:][Ee][Rr][Rr][Oo][Rr][^:]'  # don't fail for :error:badNonce
    refute_output --regexp '[Ww][Aa][Rr][Nn][Ii][Nn][Gg]'
}


@test "Force renewal of certificate using DNS-01 (dig)" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    run ${CODE_DIR}/getssl -d -f $GETSSL_HOST
    assert_success
    assert_output --partial "dig"
    refute_output --regexp '[Ff][Aa][Ii][Ll][Ee][Dd]'
    refute_output --regexp '[^:][Ee][Rr][Rr][Oo][Rr][^:]'  # don't fail for :error:badNonce
    refute_output --regexp '[Ww][Aa][Rr][Nn][Ii][Nn][Gg]'
    cleanup_environment
}
