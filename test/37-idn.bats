#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'

setup_file() {
    if [ -z "$STAGING" ]; then
        export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
        GETSSL_CMD_HOST=${GETSSL_HOST/getssl/xn--t-r1a81lydm69gz81r}
        curl --silent -X POST -d '{"host":"'$GETSSL_CMD_HOST'", "addresses":["'$GETSSL_IP'"]}' http://10.30.50.3:8055/add-a
    fi
}

# This is run for every test
setup() {
    GETSSL_CMD_HOST=${GETSSL_HOST/getssl/xn--t-r1a81lydm69gz81r}

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
    # use the test description to move tools we didn't want to test back
    DNS_TOOL=${BATS_TEST_DESCRIPTION##*-}
    for tool in dig drill host nslookup
    do
        if [[ "$tool" != "$DNS_TOOL" && -f /usr/bin/${tool}.getssl ]]; then
            mv /usr/bin/${tool}.getssl /usr/bin/${tool}
        fi
    done
}

teardown_file() {
    if [ -z "$STAGING" ]; then
        curl --silent -X POST -d '{"host":"'$GETSSL_CMD_HOST'", "addresses":["'$GETSSL_IP'"]}' http://10.30.50.3:8055/clear-a
    fi
}

@test "Check that DNS-01 verification works if the domain is idn:dig" {
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
    create_certificate -d

    assert_success
    assert_output --partial "drill"
    check_output_for_errors "debug"
}
