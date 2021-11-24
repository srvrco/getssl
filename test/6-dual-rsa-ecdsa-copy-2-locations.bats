#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# These are run for every test, not once per file
setup() {
    [ ! -f $BATS_RUN_TMPDIR/failed.skip ] || skip "skipping tests after first failure"
}


teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch $BATS_RUN_TMPDIR/failed.skip
}


setup_file() {
    if [ -z "$STAGING" ]; then
        export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
        curl --silent -X POST -d '{"host":"'a.$GETSSL_HOST'", "addresses":["'$GETSSL_IP'"]}' http://10.30.50.3:8055/add-a
    fi
}


teardown_file() {
    if [ -z "$STAGING" ]; then
        curl --silent -X POST -d '{"host":"'a.$GETSSL_HOST'"}' http://10.30.50.3:8055/clear-a
    fi
}


@test "Create dual certificates and copy RSA and ECDSA chain and key to two locations" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    check_nginx
    if [ "$OLD_NGINX" = "false" ]; then
        CONFIG_FILE="getssl-http01-dual-rsa-ecdsa-2-locations.cfg"
    else
        CONFIG_FILE="getssl-http01-dual-rsa-ecdsa-2-locations-old-nginx.cfg"
    fi

    setup_environment
    mkdir -p /root/a.${GETSSL_HOST}

    init_getssl
    create_certificate
    assert_success
    check_output_for_errors
    if [ "$OLD_NGINX" = "false" ]; then
        assert_line --partial "rsa certificate installed OK on server"
        assert_line --partial "prime256v1 certificate installed OK on server"
    fi

    # Check that the RSA chain and key have been copied to both locations
    assert [ -e "/etc/nginx/pki/domain-chain.crt" ]
    assert [ -e "/root/a.${GETSSL_HOST}/domain-chain.crt" ]
    assert [ -e "/etc/nginx/pki/private/server.key" ]
    assert [ -e "/root/a.${GETSSL_HOST}/server.key" ]

    # Check that the ECDSA chain and key have been copied to both locations
    assert [ -e "/etc/nginx/pki/domain-chain.ec.crt" ]
    assert [ -e "/root/a.${GETSSL_HOST}/domain-chain.ec.crt" ]
    assert [ -e "/etc/nginx/pki/private/server.ec.key" ]
    assert [ -e "/root/a.${GETSSL_HOST}/server.ec.key" ]
}


@test "Create dual certificates and copy to two locations but not returned by server" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    check_nginx
    if [ "$OLD_NGINX" = "false" ]; then
        CONFIG_FILE="getssl-http01-dual-rsa-ecdsa-2-locations-wrong-nginx.cfg"
    else
        skip "Skipping as old nginx servers cannot return both certificates"
    fi

    setup_environment
    mkdir -p /root/a.${GETSSL_HOST}

    init_getssl
    create_certificate
    assert_failure
    assert_line --partial "prime256v1 certificate obtained but not installed on server"
}
