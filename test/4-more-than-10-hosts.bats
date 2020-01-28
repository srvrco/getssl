#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
}


@test "Create certificates for more than 10 hosts using HTTP-01 verification" {
    CONFIG_FILE="getssl-http01-10-hosts.cfg"
    setup_environment

    # Add 11 hosts to DNS (also need to be added as aliases in docker-compose.yml)
    for prefix in a b c d e f g h i j k; do
        curl -X POST -d '{"host":"'$prefix.$GETSSL_HOST'", "addresses":["'$GETSSL_IP'"]}' http://10.30.50.3:8055/add-a
    done

    init_getssl
    create_certificate
    assert_success
    refute_output --regexp '[Ff][Aa][Ii][Ll][Ee][Dd]'
    refute_output --regexp '[Ee][Rr][Rr][Oo][Rr]'
    refute_output --regexp '[Ww][Aa][Rr][Nn][Ii][Nn][Gg]'
}


@test "Force renewal of more than 10 certificates using HTTP-01" {
    #!FIXME test certificate has been updated
    run ${CODE_DIR}/getssl -f $GETSSL_HOST
    assert_success
    refute_output --regexp '[Ff][Aa][Ii][Ll][Ee][Dd]'
    refute_output --regexp '[Ee][Rr][Rr][Oo][Rr]'
    refute_output --regexp '[Ww][Aa][Rr][Nn][Ii][Nn][Gg]'
    # Remove all the dns aliases
    cleanup_environment
    for prefix in a b c d e f g h i j k; do
        curl -X POST -d '{"host":"'$prefix.$GETSSL_HOST'", "addresses":["'$GETSSL_IP'"]}' http://10.30.50.3:8055/del-a
    done
}
