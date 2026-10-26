#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


setup_file() {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal ARI/Pebble test"
    fi

    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt

    if [ -f /usr/bin/host ]; then
        mv /usr/bin/host /usr/bin/host.getssl.bak
    fi
    if [ -f /usr/bin/nslookup ]; then
        mv /usr/bin/nslookup /usr/bin/nslookup.getssl.bak
    fi
}


teardown_file() {
    if [ -f /usr/bin/host.getssl.bak ]; then
        mv /usr/bin/host.getssl.bak /usr/bin/host
    fi
    if [ -f /usr/bin/nslookup.getssl.bak ]; then
        mv /usr/bin/nslookup.getssl.bak /usr/bin/nslookup
    fi
}


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


@test "ARI issuer mismatch does not prevent DNS-01 certificate issuance (#924)" {
    CONFIG_FILE="getssl-dns01.cfg"
    setup_environment
    init_getssl

    CONFIG_PATH="${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl.cfg"
    cp "${CODE_DIR}/test/test-config/${CONFIG_FILE}" "$CONFIG_PATH"
    printf '\nARI_ENABLE="true"\n' >> "$CONFIG_PATH"

    # Obtain the initial certificate for this test's new host.
    run "${CODE_DIR}/getssl" -U -d "$GETSSL_CMD_HOST"
    assert_success
    check_output_for_errors

    CERT="${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt"
    ORIGINAL_SERIAL=$(openssl x509 -in "$CERT" -noout -serial)

    # Simulate the malformed ARI response reported in #924. Other curl requests,
    # including the DNS-01 ACME workflow, still go to the real Pebble server.
    export GETSSL_MOCK_ARI_CERTID_ERROR=1

    # Force another issuance so getssl queries ARI before requesting a replacement.
    run "${CODE_DIR}/getssl" -U -d -f "$GETSSL_CMD_HOST"
    unset GETSSL_MOCK_ARI_CERTID_ERROR

    assert_success
    assert_output --partial "path contained an Authority Key Identifier that did not match a known issuer"
    assert_output --partial "Not processing ARI renewal info"
    assert_output --partial "Requesting certificate"

    UPDATED_SERIAL=$(openssl x509 -in "$CERT" -noout -serial)
    [[ "$ORIGINAL_SERIAL" != "$UPDATED_SERIAL" ]]

    cleanup_environment
}
