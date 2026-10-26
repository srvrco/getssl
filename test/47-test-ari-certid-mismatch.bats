#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


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


@test "ARI CertID issuer mismatch does not block certificate renewal (#924)" {
    # shellcheck disable=SC2034
    CONFIG_FILE="getssl-http01.cfg"
    setup_environment
    init_getssl
    create_certificate
    assert_success
    check_output_for_errors

    CERT=${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt
    ORIGINAL_SERIAL=$(openssl x509 -in "$CERT" -noout -serial)

    export GETSSL_MOCK_ARI_CERTID_ERROR=1
    run "${CODE_DIR}/getssl" -U -d -f "$GETSSL_CMD_HOST"
    unset GETSSL_MOCK_ARI_CERTID_ERROR

    assert_success
    assert_output --partial "Authority Key Identifier that did not match a known issuer"
    assert_output --partial "Not processing ARI renewal info"
    assert_output --partial "Requesting certificate"

    UPDATED_SERIAL=$(openssl x509 -in "$CERT" -noout -serial)
    [[ "$ORIGINAL_SERIAL" != "$UPDATED_SERIAL" ]]
}