#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
}


@test "Create certificates for more than 10 hosts using HTTP-01 verification" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    CONFIG_FILE="getssl-http01-10-hosts.cfg"
    setup_environment

    # Add 11 hosts to DNS (also need to be added as aliases in docker-compose.yml)
    for prefix in a b c d e f g h i j k; do
        curl --silent -X POST -d '{"host":"'$prefix.$GETSSL_HOST'", "addresses":["'$GETSSL_IP'"]}' http://10.30.50.3:8055/add-a
    done

    init_getssl
    create_certificate
    assert_success
    check_output_for_errors
}


@test "Force renewal of more than 10 certificates using HTTP-01" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    run ${CODE_DIR}/getssl -f $GETSSL_HOST
    assert_success
    check_output_for_errors
    # Remove all the dns aliases
    cleanup_environment
    for prefix in a b c d e f g h i j k; do
        curl --silent -X POST -d '{"host":"'$prefix.$GETSSL_HOST'"}' http://10.30.50.3:8055/clear-a
    done
}
