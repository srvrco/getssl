#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


setup() {
    [ ! -f "$BATS_RUN_TMPDIR/failed.skip" ] || skip "skipping tests after first failure"
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


@test "ARI renewal window in the future skips renewal" {
    # shellcheck disable=SC2034
    CONFIG_FILE="getssl-http01.cfg"
    setup_environment
    init_getssl
    create_certificate
    assert_success
    check_output_for_errors

    CERT=${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt
    ORIGINAL_SERIAL=$(openssl x509 -in "$CERT" -noout -serial 2>/dev/null)

    configure_pebble_ari_window future "$CERT"
    run "${CODE_DIR}/getssl" -U -d "$GETSSL_CMD_HOST"

    assert_success
    assert_line --partial 'certificate has not yet reached ARI renewal window'
    check_output_for_errors

    UPDATED_SERIAL=$(openssl x509 -in "$CERT" -noout -serial 2>/dev/null)
    [[ "$ORIGINAL_SERIAL" = "$UPDATED_SERIAL" ]]
}


@test "ARI renewal window already open renews certificate" {
    # shellcheck disable=SC2034
    CONFIG_FILE="getssl-http01.cfg"
    setup_environment
    init_getssl
    create_certificate
    assert_success
    check_output_for_errors

    CERT=${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt
    ORIGINAL_SERIAL=$(openssl x509 -in "$CERT" -noout -serial 2>/dev/null)

    configure_pebble_ari_window open "$CERT"
    run "${CODE_DIR}/getssl" -U -d "$GETSSL_CMD_HOST"

    assert_success
    refute_line --partial 'certificate has not yet reached ARI renewal window'
    assert_line --regexp '"replaces":[[:space:]]*"[^"]+"'
    check_output_for_errors

    UPDATED_SERIAL=$(openssl x509 -in "$CERT" -noout -serial 2>/dev/null)
    [[ "$ORIGINAL_SERIAL" != "$UPDATED_SERIAL" ]]
}
