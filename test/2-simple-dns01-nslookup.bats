#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
    mv /usr/bin/dig /usr/bin/dig.getssl.bak
}


teardown() {
    mv /usr/bin/dig.getssl.bak /usr/bin/dig
}


@test "Create new certificate using DNS-01 verification (nslookup)" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    CONFIG_FILE="getssl-dns01.cfg"
    setup_environment
    init_getssl
    create_certificate -d
    assert_success
    assert_output --partial "nslookup"
    refute_output --regexp '[Ff][Aa][Ii][Ll][Ee][Dd]'
    refute_output --regexp '[^:][Ee][Rr][Rr][Oo][Rr][^:]'  # don't fail for :error:badNonce
    refute_output --regexp '[Ww][Aa][Rr][Nn][Ii][Nn][Gg]'
}
