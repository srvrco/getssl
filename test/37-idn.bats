#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'

# This is run for every test
setup() {
    [ ! -f $BATS_RUN_TMPDIR/failed.skip ] || skip "skipping tests after first failure"
    GETSSL_CMD_HOST=${GETSSL_IDN_HOST}

    # use the test description to move tools we don't want to test out of the way
    DNS_TOOL=${BATS_TEST_DESCRIPTION##*:}
    for tool in dig drill host nslookup
    do
        if [[ "$tool" != "$DNS_TOOL" && -f /usr/bin/$tool ]]; then
            mv /usr/bin/$tool /usr/bin/${tool}.getssl
        fi
    done
}

teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch $BATS_RUN_TMPDIR/failed.skip
    # use the test description to move tools we didn't want to test back
    DNS_TOOL=${BATS_TEST_DESCRIPTION##*-}
    for tool in dig drill host nslookup
    do
        if [[ "$tool" != "$DNS_TOOL" && -f /usr/bin/${tool}.getssl ]]; then
            mv /usr/bin/${tool}.getssl /usr/bin/${tool}
        fi
    done
}

setup_file() {
    if [ -z "$STAGING" ]; then
        export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
        curl --silent -X POST -d '{"host":"'$GETSSL_IDN_HOST'", "addresses":["'$GETSSL_IP'"]}' http://10.30.50.3:8055/add-a
    fi
}

teardown_file() {
    if [ -z "$STAGING" ]; then
        curl --silent -X POST -d '{"host":"'$GETSSL_IDN_HOST'", "addresses":["'$GETSSL_IP'"]}' http://10.30.50.3:8055/clear-a
    fi
}

@test "Check that DNS-01 verification works if the domain is idn:dig" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    CONFIG_FILE="getssl-dns01.cfg"

    setup_environment
    init_getssl
    create_certificate

    assert_success
    assert_output --partial "dig"
    check_output_for_errors
}

@test "Check that DNS-01 verification works if the domain is idn:drill" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    if [ ! -f /usr/bin/drill ]; then
        # Can't find drill package for centos8 / rockylinux8
        skip "Drill not installed on this system"
    fi

    CONFIG_FILE="getssl-dns01.cfg"

    setup_environment
    init_getssl
    create_certificate

    assert_success
    assert_output --partial "drill"
    check_output_for_errors
}
