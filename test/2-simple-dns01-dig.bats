#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


setup_file() {
    if [ -z "$STAGING" ]; then
        export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
    fi
    if [ -f /usr/bin/host ]; then
        mv /usr/bin/host /usr/bin/host.getssl.bak
    fi
    if [ -f /usr/bin/nslookup ]; then
        mv /usr/bin/nslookup /usr/bin/nslookup.getssl.bak
    fi
}


teardown_file() {
    if [ -f /usr/bin/host.getssl.bak ]; then
        mv /usr/bin/host.getssl.bak /usr/bin/host
    fi
    if [ -f /usr/bin/nslookup.getssl.bak ]; then
        mv /usr/bin/nslookup.getssl.bak /usr/bin/nslookup
    fi
}


setup() {
    [ ! -f $BATS_RUN_TMPDIR/failed.skip ] || skip "skipping tests after first failure"
}


teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch $BATS_RUN_TMPDIR/failed.skip
}


@test "Create new certificate using DNS-01 verification (dig)" {
    CONFIG_FILE="getssl-dns01.cfg"

    setup_environment
    init_getssl
    create_certificate
    assert_success
    assert_output --partial "dig"
    check_output_for_errors
}


@test "Force renewal of certificate using DNS-01 (dig)" {
    run ${CODE_DIR}/getssl -U -d -f $GETSSL_HOST
    assert_success
    assert_output --partial "dig"
    check_output_for_errors
    cleanup_environment
}
