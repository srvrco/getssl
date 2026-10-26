#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# Verifies the caller of renew_ari(): when the ARI request cannot be used for a
# certificate (here a 404 because the issuer is not known to the CA, see #924),
# the result must be treated like "ARI not available" so the normal RENEW_ALLOW /
# expiry checks decide whether to renew.
#
# This test deliberately runs WITHOUT -f: a forced renewal bypasses the expiry
# checks, which would hide a broken fallback in the main flow.

setup() {
    [ ! -f "$BATS_RUN_TMPDIR/failed.skip" ] || skip "skipping tests after first failure"

    cat << 'MOCK_CURL' > /getssl/test/curl
#!/usr/bin/env bash
if [[ "${GETSSL_MOCK_ARI_CERTID_ERROR:-}" == "1" ]] &&
   [[ "$*" == *"/renewal-info/"* || "$*" == *"/renewalInfo/"* ]]; then
    echo '{"type":"urn:ietf:params:acme:error:malformed","detail":"While parsing ARI CertID an error occurred :: path contained an Authority Key Identifier that did not match a known issuer","status":404}'
    exit 0
fi
export PATH="${PATH#/getssl/test:}"
REAL_CURL=$(command -v curl)
exec "$REAL_CURL" "$@"
MOCK_CURL
    chmod +x /getssl/test/curl
}


teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch "$BATS_RUN_TMPDIR/failed.skip"
    rm -f /getssl/test/curl
}


setup_file() {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal ARI/Pebble test"
    fi
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
}


@test "ARI failure falls back to the expiry checks and still renews (#924)" {
    # shellcheck disable=SC2034
    CONFIG_FILE="getssl-http01.cfg"
    setup_environment
    init_getssl
    create_certificate
    assert_success
    check_output_for_errors

    CERT="${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt"
    ORIGINAL_SERIAL=$(openssl x509 -in "$CERT" -noout -serial)

    # Make the normal expiry checks consider the certificate due for renewal, so
    # the only thing that can stop the renewal is the ARI result.
    CONFIG_PATH="${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl.cfg"
    printf '\nRENEW_ALLOW="36500"\n' >> "$CONFIG_PATH"

    export GETSSL_MOCK_ARI_CERTID_ERROR=1
    run "${CODE_DIR}/getssl" -U -d "$GETSSL_CMD_HOST"
    unset GETSSL_MOCK_ARI_CERTID_ERROR

    assert_success
    assert_output --partial "did not match a known issuer"
    assert_output --partial "Not processing ARI renewal info"
    assert_output --partial "No ARI renewal information available, using normal renewal checks"
    assert_output --partial "Requesting certificate"
    refute_output --partial "not yet reached ARI renewal window"
    refute_output --partial "Warning"

    UPDATED_SERIAL=$(openssl x509 -in "$CERT" -noout -serial)
    [[ "$ORIGINAL_SERIAL" != "$UPDATED_SERIAL" ]]
}
