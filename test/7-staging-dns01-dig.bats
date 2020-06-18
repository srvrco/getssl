#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'



@test "Create new certificate using staging server, dig and DuckDNS" {
    skip
    if [ -z "$STAGING" ]; then
        skip "Running internal tests, skipping external test"
    fi
    CONFIG_FILE="getssl-staging-dns01.cfg"

    setup_environment
    init_getssl
    create_certificate
    assert_success
    check_output_for_errors
}

@test "Force renewal of certificate using staging server, dig and DuckDNS" {
    skip
    if [ -z "$STAGING" ]; then
        skip "Running internal tests, skipping external test"
    fi
    run ${CODE_DIR}/getssl -f $GETSSL_HOST
    assert_success
    check_output_for_errors
    cleanup_environment
}
