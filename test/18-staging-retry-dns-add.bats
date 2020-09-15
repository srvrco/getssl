#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'



@test "Check retry add dns command if dns isn't updated (DuckDNS)" {
    if [ -z "$STAGING" ]; then
        skip "Running internal tests, skipping external test"
    fi
    CONFIG_FILE="getssl-staging-dns01-fail-dns-add.cfg"

    setup_environment
    init_getssl
    create_certificate -d
    assert_failure
    assert_line --partial "Retrying adding dns via command"
}
