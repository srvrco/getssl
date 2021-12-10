#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    [ ! -f $BATS_RUN_TMPDIR/failed.skip ] || skip "skipping tests after first failure"
    if [ -z "$STAGING" ]; then
        export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
    fi
    if [ -f /usr/bin/dig ]; then
        mv /usr/bin/dig /usr/bin/dig.getssl.bak
    fi
    if [ -f /usr/bin/drill ]; then
        mv /usr/bin/drill /usr/bin/drill.getssl.bak
    fi
    if [ -f /usr/bin/host ]; then
        mv /usr/bin/host /usr/bin/host.getssl.bak
    fi
}


teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch $BATS_RUN_TMPDIR/failed.skip
    if [ -f /usr/bin/dig.getssl.bak ]; then
        mv /usr/bin/dig.getssl.bak /usr/bin/dig
    fi
    if [ -f /usr/bin/drill.getssl.bak ]; then
        mv /usr/bin/drill.getssl.bak /usr/bin/drill
    fi
    if [ -f /usr/bin/host.getssl.bak ]; then
        mv /usr/bin/host.getssl.bak /usr/bin/host
    fi
}


@test "Create new certificate using DNS-01 verification (nslookup)" {
    CONFIG_FILE="getssl-dns01.cfg"

    setup_environment
    init_getssl
    create_certificate
    assert_success
    assert_output --partial "nslookup"
    check_output_for_errors "debug"
}
