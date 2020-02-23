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


@test "Create new certificate using staging server and DuckDNS" {
    if [ -z "$STAGING" ]; then
        skip "Running internal tests, skipping external test"
    fi
    CONFIG_FILE="getssl-duckdns01.cfg"

    setup_environment
    init_getssl
    create_certificate
    assert_success
    refute_output --regexp '[Ff][Aa][Ii][Ll][Ee][Dd]'
    refute_output --regexp '[Ee][Rr][Rr][Oo][Rr]'
    refute_output --regexp '[Ww][Aa][Rr][Nn][Ii][Nn][Gg]'
}

@test "Force renewal of certificate using staging server and DuckDNS" {
    if [ -z "$STAGING" ]; then
        skip "Running internal tests, skipping external test"
    fi
    run ${CODE_DIR}/getssl -f $GETSSL_HOST
    assert_success
    refute_output --regexp '[Ff][Aa][Ii][Ll][Ee][Dd]'
    refute_output --regexp '[Ee][Rr][Rr][Oo][Rr]'
    refute_output --regexp '[Ww][Aa][Rr][Nn][Ii][Nn][Gg]'
    cleanup_environment
    curl --silent -X POST -d '{"host":"getssl.duckdns.org", "addresses":["'$GETSSL_IP'"]}' http://10.30.50.3:8055/del-a
}
