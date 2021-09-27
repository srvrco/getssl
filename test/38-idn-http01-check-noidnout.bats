#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'

setup() {
    [ ! -f $BATS_RUN_TMPDIR/failed.skip ] || skip "skipping tests after first failure"
    GETSSL_CMD_HOST=$GETSSL_IDN_HOST
}

teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch $BATS_RUN_TMPDIR/failed.skip
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

@test "Ensure noidnout in check_config isn't passed to host and nslookup (HTTP-01)" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    CONFIG_FILE="getssl-http01.cfg"
    setup_environment
    init_getssl
    cat <<- EOF > ${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg
SANS="${GETSSL_HOST}"
USE_SINGLE_ACL="true"
EOF

    create_certificate --check-config

    assert_success
    refute_output --partial "DNS lookup using host  +noidnout"
    refute_output --partial "DNS lookup using nslookup  +noidnout"
    refute_output --partial "+noidnout $GETSSL_HOST"
    check_output_for_errors
}
