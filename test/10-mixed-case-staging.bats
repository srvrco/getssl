#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


@test "Check can create certificate if domain is not lowercase using staging server and DuckDNS" {
    if [ -z "$STAGING" ]; then
        skip "Running internal tests, skipping external test"
    fi

    CONFIG_FILE="getssl-staging-dns01.cfg"
    GETSSL_CMD_HOST=$(echo $GETSSL_HOST | tr a-z A-Z)

    setup_environment
    init_getssl
    create_certificate

    assert_success
    check_output_for_errors
}
