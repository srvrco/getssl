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
}


setup_file() {
    if [ -z "$STAGING" ]; then
        export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
        # Add 11 hosts to DNS (also need to be added as aliases in docker-compose.yml)
        for prefix in a b c d e f g h i j k; do
            curl --silent -X POST -d '{"host":"'$prefix.$GETSSL_HOST'", "addresses":["'$GETSSL_IP'"]}' http://10.30.50.3:8055/add-a
        done
    fi
}


teardown_file() {
    # Remove all the dns aliases
    if [ -n "$STAGING" ]; then
        for prefix in a b c d e f g h i j k; do
            curl --silent -X POST -d '{"host":"'$prefix.$GETSSL_HOST'"}' http://10.30.50.3:8055/clear-a
        done
    fi
}


@test "Create certificates for more than 10 hosts using HTTP-01 verification" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    CONFIG_FILE="getssl-http01-10-hosts.cfg"
    setup_environment

    init_getssl
    create_certificate
    assert_success
    check_output_for_errors
}


@test "Force renewal of more than 10 certificates using HTTP-01" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    run ${CODE_DIR}/getssl -U -d -f $GETSSL_HOST
    assert_success
    check_output_for_errors
    cleanup_environment
}
