#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'

# This is run for every test
teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch $BATS_RUN_TMPDIR/failed.skip
}

setup() {
    [ ! -f $BATS_RUN_TMPDIR/failed.skip ] || skip "skipping tests after first failure"
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
}


@test "Check retry add dns command if dns isn't updated" {
    if [ -n "$STAGING" ]; then
        skip "Running internal tests, skipping external test"
    fi

    CONFIG_FILE="getssl-dns01.cfg"

    setup_environment
    init_getssl

    cat <<- EOF > ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg
DNS_ADD_COMMAND="/getssl/test/dns_add_fail"

# Speed up the test by reducing the number or retries and the wait between retries.
DNS_WAIT=2
DNS_WAIT_COUNT=11
DNS_EXTRA_WAIT=0
CHECK_ALL_AUTH_DNS="false"
CHECK_PUBLIC_DNS_SERVER="false"
DNS_WAIT_RETRY_ADD="true"
EOF
    create_certificate
    assert_failure
    assert_line --partial "Retrying adding DNS via command"
}
