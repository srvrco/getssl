#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# Unit tests for renew_ari() and how getssl interprets the response from the
# ACME Renewal Information (ARI) endpoint.
# A 404 from the CA means it has no information for the certificate (it was
# issued by a different CA, it has already been replaced, or its issuer is no
# longer known to the CA), so getssl must not warn and must fall back to the
# normal expiry based renewal checks (see issue #924).

setup() {
    [ ! -f "$BATS_RUN_TMPDIR/failed.skip" ] || skip "skipping tests after first failure"

    . /getssl/getssl --source

    API=2
    _USE_DEBUG=1
    _QUIET=0
    _NOMETER=""
    CURL_USERAGENT="getssl-test"
    URL_renewInfo="https://pebble:14000/renewal-info"
    CERT_FILE="/getssl/pebble-certificates/cert.pem"
    DOMAIN="getssl.test"

    _ARI_STARTTIME=""
    _REPLACES=""

    FUTURE_EXPIRY=$(( $(date +%s) + 30 * 24 * 60 * 60 ))
    PAST_EXPIRY=$(( $(date +%s) - 24 * 60 * 60 ))
}


teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch "$BATS_RUN_TMPDIR/failed.skip"
}


# Stub for curl: returns ARI_BODY as the response body and ARI_CODE as the
# status code appended by "curl --write-out". ARI_CODE can be empty to mimic
# mocks that only return the body.
curl() {
    [[ -z "${ARI_BODY-}" ]] || printf '%s' "$ARI_BODY"
    [[ -z "${ARI_CODE-}" ]] || printf '\n%s' "$ARI_CODE"
}


@test "renew_ari returns 0 and sets _REPLACES when the window is open" {
    ARI_BODY='{"suggestedWindow":{"start":"2020-01-01T00:00:00Z","end":"2020-01-02T00:00:00Z"}}'
    ARI_CODE=200

    renew_ari "$FUTURE_EXPIRY" >/dev/null 2>&1
    result=$?

    assert_equal "$result" "0"
    assert_equal "$_REPLACES" "${aki}.${serialb64}"
}


@test "renew_ari returns 1 when the window is in the future" {
    ARI_BODY='{"suggestedWindow":{"start":"2099-01-01T00:00:00Z","end":"2099-01-02T00:00:00Z"}}'
    ARI_CODE=200

    run renew_ari "$FUTURE_EXPIRY"

    assert_equal "$status" "1"
    assert_output --partial "Not within ARI renewal window"
    refute_output --partial "Within ARI renewal window, using ARI"
}


@test "renew_ari returns 2 without a warning when the CA does not know the certificate" {
    ARI_BODY='{"type":"urn:ietf:params:acme:error:malformed","detail":"While parsing ARI CertID an error occurred :: path contained an Authority Key Identifier that did not match a known issuer","status":404}'
    ARI_CODE=404

    run renew_ari "$FUTURE_EXPIRY"

    assert_equal "$status" "2"
    assert_output --partial "did not match a known issuer"
    assert_output --partial "Not processing ARI renewal info"
    refute_output --partial "Warning"
}


@test "renew_ari returns 2 when only the response body contains the 404 status" {
    ARI_BODY='{"type":"urn:ietf:params:acme:error:malformed","detail":"path contained an Authority Key Identifier that did not match a known issuer","status":404}'
    ARI_CODE=""

    run renew_ari "$FUTURE_EXPIRY"

    assert_equal "$status" "2"
    assert_output --partial "Not processing ARI renewal info"
    refute_output --partial "Warning"
}


@test "renew_ari returns 2 on an empty response without a fatal date error" {
    ARI_BODY=""
    ARI_CODE=""

    run renew_ari "$FUTURE_EXPIRY"

    assert_equal "$status" "2"
    assert_output --partial "Not processing ARI renewal info"
    refute_output --partial "Failed to parse date"
}


@test "renew_ari returns 2 and warns on a server error" {
    ARI_BODY='{"type":"urn:ietf:params:acme:error:serverInternal","detail":"Error determining renewal window","status":500}'
    ARI_CODE=500

    run renew_ari "$FUTURE_EXPIRY"

    assert_equal "$status" "2"
    assert_output --partial "Warning: ARI query returned"
    assert_output --partial "Not processing ARI renewal info"
}


@test "renew_ari returns 2 on an invalid renewal window without a fatal date error" {
    ARI_BODY='{"suggestedWindow":{"start":"not-a-date","end":"also-bad"}}'
    ARI_CODE=200

    run renew_ari "$FUTURE_EXPIRY"

    assert_equal "$status" "2"
    assert_output --partial "Not processing ARI renewal info"
    refute_output --partial "Failed to parse date"
}


@test "renew_ari does not query ARI for an expired certificate" {
    ARI_BODY='{"suggestedWindow":{"start":"2020-01-01T00:00:00Z","end":"2020-01-02T00:00:00Z"}}'
    ARI_CODE=200

    run renew_ari "$PAST_EXPIRY"

    assert_equal "$status" "0"
    assert_output --partial "Certificate expired, not fetching ARI info"
    refute_output --partial "ARI response"
}
