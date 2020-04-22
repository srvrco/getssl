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
    check_output_for_errors "debug"
}


@test "Force renewal of certificate using DNS-01 (dig)" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    run ${CODE_DIR}/getssl -d -f $GETSSL_HOST
    assert_success
    assert_output --partial "dig"
    check_output_for_errors "debug"
    cleanup_environment
}
