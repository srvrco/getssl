#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


setup() {
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
    if [ -f /usr/bin/host ]; then
        mv /usr/bin/host /usr/bin/host.getssl.bak
    fi
    if [ -f /usr/bin/nslookup ]; then
        mv /usr/bin/nslookup /usr/bin/nslookup.getssl.bak
    fi
}


teardown() {
    if [ -f /usr/bin/host.getssl.bak ]; then
        mv /usr/bin/host.getssl.bak /usr/bin/host
    fi
    if [ -f /usr/bin/nslookup.getssl.bak ]; then
        mv /usr/bin/nslookup.getssl.bak /usr/bin/nslookup
    fi
}


@test "Create new certificate using DNS-01 verification (dig)" {
    CONFIG_FILE="getssl-dns01.cfg"
    if [ -n "$STAGING" ]; then
        CONFIG_FILE="getssl-staging-dns01.cfg"
    fi

    setup_environment
    init_getssl
    create_certificate -d
    assert_success
    assert_output --partial "dig"
    check_output_for_errors "debug"
}


@test "Force renewal of certificate using DNS-01 (dig)" {
    run ${CODE_DIR}/getssl -d -f $GETSSL_HOST
    assert_success
    assert_output --partial "dig"
    check_output_for_errors "debug"
    cleanup_environment
}
