#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    [ ! -f $BATS_RUN_TMPDIR/failed.skip ] || skip "skipping tests after first failure"
}


teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch $BATS_RUN_TMPDIR/failed.skip
}


setup_file() {
    # Add hosts to DNS (also need to be added as aliases in docker-compose.yml)
    if [ -z "$STAGING" ]; then
        export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
        for prefix in a b c; do
            curl --silent -X POST -d '{"host":"'$prefix.$GETSSL_HOST'", "addresses":["'$GETSSL_IP'"]}' http://10.30.50.3:8055/add-a
        done
    fi
}


teardown_file() {
    if [ -z "$STAGING" ]; then
        for prefix in a b c; do
            curl --silent -X POST -d '{"host":"'$prefix.$GETSSL_HOST'"}' http://10.30.50.3:8055/clear-a
        done
    fi
}


@test "Test behaviour if SANS line is space separated instead of comma separated (http01)" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    CONFIG_FILE="getssl-http01-spaces-sans.cfg"
    setup_environment

    init_getssl
    create_certificate
    assert_success
    check_output_for_errors
}


@test "Test renewal if SANS line is space separated instead of comma separated (http01)" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    run ${CODE_DIR}/getssl -U -d -f $GETSSL_HOST
    assert_success
    check_output_for_errors
    cleanup_environment
}


@test "Test behaviour if SANS line is space separated and IGNORE_DIRECTORY_DOMAIN (http01)" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    CONFIG_FILE="getssl-http01-spaces-sans-and-ignore-dir-domain.cfg"
    setup_environment

    init_getssl
    create_certificate
    assert_success
    check_output_for_errors
}


@test "Test renewal if SANS line is space separated and IGNORE_DIRECTORY_DOMAIN (http01)" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    run ${CODE_DIR}/getssl -U -d -f $GETSSL_HOST
    assert_success
    check_output_for_errors
    cleanup_environment
}


@test "Test behaviour if SANS line is comma and space separated (http01)" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    CONFIG_FILE="getssl-http01-spaces-and-commas-sans.cfg"
    setup_environment

    init_getssl
    create_certificate
    assert_success
    check_output_for_errors
    cleanup_environment
}
