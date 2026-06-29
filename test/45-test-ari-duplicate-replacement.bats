#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'

# This test confirms a bug reported with the ARI support in #908.
# There's an issue that if a certificate is renewed twice (e.g. if it's not updated
# successfully) then the renewal process tries to create a new order with the
# replaces field is a cert that had already been replaced. When this happens,
# Let's Encrypt currently responds with HTTP 409 (Conflict) and the error
# urn:ietf:params:acme:error:conflict


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


@test "ARI renewal of an already-replaced certificate returns 409 and fails" {
    # shellcheck disable=SC2034
    CONFIG_FILE="getssl-http01.cfg"
    setup_environment
    init_getssl
    create_certificate
    assert_success
    check_output_for_errors

    CERT=${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt
    ORIGINAL_SERIAL=$(openssl x509 -in "$CERT" -noout -serial)

    # Save the original certificate so it can be restored after the first renewal.
    ORIGINAL_CERT_COPY=$(mktemp)
    cp "$CERT" "$ORIGINAL_CERT_COPY"

    # 1. First renewal: open the ARI window for the original cert and renew.
    #    This creates the replacement order on the server for the original cert.
    configure_pebble_ari_window open "$CERT"
    run "${CODE_DIR}/getssl" -U -d "$GETSSL_CMD_HOST"

    assert_success
    assert_line --partial "Within ARI renewal window, using ARI"
    check_output_for_errors

    RENEWED_SERIAL=$(openssl x509 -in "$CERT" -noout -serial)
    [[ "$ORIGINAL_SERIAL" != "$RENEWED_SERIAL" ]]

    # 2. Restore the original certificate. The server still holds the replacement
    #    order from step 1, keyed on the original cert's ARI identifier.
    cp "$ORIGINAL_CERT_COPY" "$CERT"
    RESTORED_SERIAL=$(openssl x509 -in "$CERT" -noout -serial)
    [[ "$RESTORED_SERIAL" = "$ORIGINAL_SERIAL" ]]

    # 3. Second renewal: re-open the ARI window for the restored original and
    #    attempt to renew again. getssl reuses the original cert's ARI id as the
    #    "replaces" value, colliding with the existing replacement order.
    configure_pebble_ari_window open "$CERT"
    run "${CODE_DIR}/getssl" -U -d "$GETSSL_CMD_HOST"

    # The server rejects the duplicate replacement with 409 Conflict. The
    # response body is logged in the debug output.
    assert_output --partial "already has a replacement order"

    assert_success

    rm -f "$ORIGINAL_CERT_COPY"
}
