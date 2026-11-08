#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


setup() {
    [ ! -f "$BATS_RUN_TMPDIR/failed.skip" ] || skip "skipping tests after first failure"

    export -f curl
}


curl() {
    if [[ -n "$GETSSL_TEST_ARI_RESPONSE" ]] &&
       [[ "$*" == *"/renewal-info/"* || "$*" == *"/renewalInfo/"* ]]; then
        printf '%s\n200' "$GETSSL_TEST_ARI_RESPONSE"
        return 0
    fi
    command curl "$@"
}


teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch "$BATS_RUN_TMPDIR/failed.skip"
}


setup_file() {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal ARI/Pebble test"
    fi
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
}


@test "an invalid past ARI window does not renew a young certificate" {
    CONFIG_FILE="getssl-http01.cfg"
    setup_environment
    init_getssl
    echo 'PROFILE="default"' > "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg"
    create_certificate
    assert_success
    check_output_for_errors

    CERT="${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt"
    ORIGINAL_SERIAL=$(openssl x509 -in "$CERT" -noout -serial)
    printf '\nRENEW_ALLOW="1"\n' >> "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl.cfg"

    export GETSSL_TEST_ARI_RESPONSE='{"suggestedWindow":{"start":"2020-01-01T00:00:00Z","end":"2020-01-01T00:00:00Z"}}'
    run "${CODE_DIR}/getssl" -U -d "$GETSSL_CMD_HOST"
    unset GETSSL_TEST_ARI_RESPONSE

    assert_success
    assert_output --partial "Not processing ARI renewal info"
    assert_output --partial "No ARI renewal information available, using normal renewal checks"
    assert_output --partial "certificate is valid for more than"
    refute_output --partial "Requesting certificate"

    UPDATED_SERIAL=$(openssl x509 -in "$CERT" -noout -serial)
    assert_equal "$UPDATED_SERIAL" "$ORIGINAL_SERIAL"
}


@test "an invalid future ARI window does not block a certificate due for renewal" {
    CONFIG_FILE="getssl-http01.cfg"
    setup_environment
    init_getssl
    echo 'PROFILE="default"' > "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg"
    create_certificate
    assert_success
    check_output_for_errors

    CERT="${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt"
    ORIGINAL_SERIAL=$(openssl x509 -in "$CERT" -noout -serial)
    printf '\nRENEW_ALLOW="90"\n' >> "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl.cfg"

    export GETSSL_TEST_ARI_RESPONSE='{"suggestedWindow":{"start":"2099-01-02T00:00:00Z","end":"2099-01-01T00:00:00Z"}}'
    run "${CODE_DIR}/getssl" -U -d "$GETSSL_CMD_HOST"
    unset GETSSL_TEST_ARI_RESPONSE

    assert_success
    assert_output --partial "Not processing ARI renewal info"
    assert_output --partial "No ARI renewal information available, using normal renewal checks"
    assert_output --partial "Requesting certificate"
    refute_output --partial "not yet reached ARI renewal window"

    UPDATED_SERIAL=$(openssl x509 -in "$CERT" -noout -serial)
    [[ "$UPDATED_SERIAL" != "$ORIGINAL_SERIAL" ]]
}
