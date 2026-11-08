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

    # Sourcing with --source skips the main flow, so detect the OS here.
    # Without this, date_rfc3339 uses GNU date syntax on busybox based images
    # (e.g. bash4-0) and cannot convert the ARI renewal window.
    get_os

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


@test "renew_ari compares renewal window endpoints with different UTC offsets" {
    ARI_BODY='{"suggestedWindow":{"start":"2020-01-01T01:00:00+01:00","end":"2020-01-01T00:30:00Z"}}'
    ARI_CODE=200

    run renew_ari "$FUTURE_EXPIRY"

    assert_equal "$status" "0"
    assert_output --partial "Within ARI renewal window, using ARI"
}


@test "renew_ari compares fractional seconds without rounding the window" {
    for window in '1 9 0' '10 100 2' '9 1 2' '09 1 0'; do
        read -r start_fraction end_fraction expected <<< "$window"
        ARI_BODY='{"suggestedWindow":{"start":"2020-01-01T00:00:00.'"$start_fraction"'Z","end":"2020-01-01T00:00:00.'"$end_fraction"'Z"}}'
        ARI_CODE=200

        run renew_ari "$FUTURE_EXPIRY"

        assert_equal "$status" "$expected"
    done
}


@test "renew_ari rejects malformed timestamps and nonexistent dates" {
    for end in \
        '2020-01-02T00:00:00' \
        '2020-01-02T00:00:00Z next day' \
        '2020-02-31T00:00:00Z' \
        '2100-02-29T00:00:00Z' \
        '2020-13-01T00:00:00Z' \
        '2020-01-00T00:00:00Z' \
        '2020-01-02T24:00:00Z' \
        '2020-01-02T00:00:00+99:99'; do
        ARI_BODY='{"suggestedWindow":{"start":"2020-01-01T00:00:00Z","end":"'"$end"'"}}'
        ARI_CODE=200

        run renew_ari "$FUTURE_EXPIRY"

        assert_equal "$status" "2"
        assert_output --partial "Not processing ARI renewal info"
    done
}


@test "renew_ari accepts leap days and lowercase timestamp separators" {
    ARI_BODY='{"suggestedWindow":{"start":"2000-02-29t00:00:00z","end":"2000-03-01t00:00:00z"}}'
    ARI_CODE=200

    run renew_ari "$FUTURE_EXPIRY"

    assert_equal "$status" "0"
    assert_output --partial "Within ARI renewal window, using ARI"
}


@test "renew_ari returns 2 when different offsets describe equal endpoints" {
    ARI_BODY='{"suggestedWindow":{"start":"2020-01-01T00:00:00Z","end":"2019-12-31T23:00:00-01:00"}}'
    ARI_CODE=200

    run renew_ari "$FUTURE_EXPIRY"

    assert_equal "$status" "2"
    assert_output --partial "Not processing ARI renewal info"
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


@test "renew_ari returns 2 when the renewal window has no end" {
    ARI_BODY='{"suggestedWindow":{"start":"2020-01-01T00:00:00Z"}}'
    ARI_CODE=200

    run renew_ari "$FUTURE_EXPIRY"

    assert_equal "$status" "2"
    assert_output --partial "Not processing ARI renewal info"
}


@test "renew_ari returns 2 when the renewal window end cannot be parsed" {
    ARI_BODY='{"suggestedWindow":{"start":"2020-01-01T00:00:00Z","end":"2020-01-02Tnot-a-time"}}'
    ARI_CODE=200

    run renew_ari "$FUTURE_EXPIRY"

    assert_equal "$status" "2"
    assert_output --partial "Not processing ARI renewal info"
    refute_output --partial "Failed to parse date"
}


@test "renew_ari returns 2 when the renewal window start cannot be parsed" {
    ARI_BODY='{"suggestedWindow":{"start":"2020-01-01Tnot-a-time","end":"2020-01-02T00:00:00Z"}}'
    ARI_CODE=200

    TEMP_DIR="$BATS_TEST_TMPDIR/renewal"
    DOMAIN_DIR="$BATS_TEST_TMPDIR"
    mkdir "$TEMP_DIR"
    touch "$TEMP_DIR/pending"

    run renew_ari "$FUTURE_EXPIRY"

    assert_equal "$status" "2"
    assert_output --partial "Not processing ARI renewal info"
    refute_output --partial "Failed to parse date"
    assert_file_exists "$TEMP_DIR/pending"
}


@test "renew_ari returns 2 when the renewal window end equals its start" {
    ARI_BODY='{"suggestedWindow":{"start":"2020-01-01T00:00:00Z","end":"2020-01-01T00:00:00Z"}}'
    ARI_CODE=200

    run renew_ari "$FUTURE_EXPIRY"

    assert_equal "$status" "2"
    assert_output --partial "Not processing ARI renewal info"
}


@test "renew_ari returns 2 when the renewal window end precedes its start" {
    ARI_BODY='{"suggestedWindow":{"start":"2020-01-02T00:00:00Z","end":"2020-01-01T00:00:00Z"}}'
    ARI_CODE=200

    run renew_ari "$FUTURE_EXPIRY"

    assert_equal "$status" "2"
    assert_output --partial "Not processing ARI renewal info"
}


@test "renew_ari returns 2 for a reversed renewal window in the future" {
    ARI_BODY='{"suggestedWindow":{"start":"2099-01-02T00:00:00Z","end":"2099-01-01T00:00:00Z"}}'
    ARI_CODE=200

    run renew_ari "$FUTURE_EXPIRY"

    assert_equal "$status" "2"
    assert_output --partial "Not processing ARI renewal info"
    refute_output --partial "Not within ARI renewal window"
}


@test "renew_ari does not query ARI for an expired certificate" {
    ARI_BODY='{"suggestedWindow":{"start":"2020-01-01T00:00:00Z","end":"2020-01-02T00:00:00Z"}}'
    ARI_CODE=200

    run renew_ari "$PAST_EXPIRY"

    assert_equal "$status" "0"
    assert_output --partial "Certificate expired, not fetching ARI info"
    refute_output --partial "ARI response"
}
