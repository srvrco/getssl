#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    [ ! -f $BATS_RUN_TMPDIR/failed.skip ] || skip "skipping tests after first failure"

    . /getssl/getssl --source
    export API=2
    _USE_DEBUG=1
}


teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch $BATS_RUN_TMPDIR/failed.skip
}


# Valid tokens

@test "validate_token: accept valid base64url token (no padding)" {
    run validate_token "kD1H4FVIEFvkWghLlKFoSPpR5u0FTGkRs4A_FnTfv3A"
    assert_success
    assert_output ""
}


@test "validate_token: accept token with dashes" {
    run validate_token "abc-xyz-123"
    assert_success
    assert_output ""
}


@test "validate_token: accept token with underscores" {
    run validate_token "abc_xyz_123"
    assert_success
    assert_output ""
}


@test "validate_token: accept single character token" {
    run validate_token "a"
    assert_success
    assert_output ""
}


@test "validate_token: accept maximum length token (255 chars)" {
    token=$(printf 'a%.0s' {1..255})
    run validate_token "$token"
    assert_success
}


# Invalid tokens

@test "validate_token: reject token with semicolon" {
    run validate_token "abc;touch /tmp/pwned"
    assert_failure
    assert_output --partial "Invalid token"
}


@test "validate_token: reject token with path traversal" {
    run validate_token "../../../etc/passwd"
    assert_failure
    assert_output --partial "Invalid token"
}


@test "validate_token: reject token with backticks" {
    run validate_token 'abc`touch /tmp/pwned`'
    assert_failure
    assert_output --partial "Invalid token"
}


@test "validate_token: reject token with command substitution" {
    run validate_token 'abc$(touch /tmp/pwned)'
    assert_failure
    assert_output --partial "Invalid token"
}


@test "validate_token: reject token with pipe" {
    run validate_token "abc|sh"
    assert_failure
    assert_output --partial "Invalid token"
}


@test "validate_token: reject token with spaces" {
    run validate_token "abc def"
    assert_failure
    assert_output --partial "Invalid token"
}


@test "validate_token: reject token with forward slash" {
    run validate_token "abc/def"
    assert_failure
    assert_output --partial "Invalid token"
}


@test "validate_token: reject token with newline" {
    run validate_token "$(echo -e 'abc\ndef')"
    assert_failure
    assert_output --partial "Invalid token"
}


@test "validate_token: reject token exceeding 255 characters" {
    token=$(printf 'a%.0s' {1..256})
    run validate_token "$token"
    assert_failure
    assert_output --partial "Invalid token"
}


@test "validate_token: reject empty token" {
    run validate_token ""
    assert_failure
    assert_output --partial "Invalid token"
}


@test "validate_token: reject token with equals sign (base64 padding)" {
    # RFC 8555 requires trailing '=' to be stripped
    run validate_token "abc123=="
    assert_failure
    assert_output --partial "Invalid token"
}


# Negative assertions: tokens that should NOT match the regex

@test "validate_token: reject token with ampersand" {
    run validate_token "abc&def"
    assert_failure
    assert_output --partial "Invalid token"
}


@test "validate_token: reject token with hash" {
    run validate_token "abc#def"
    assert_failure
    assert_output --partial "Invalid token"
}


@test "validate_token: reject token with null byte" {
    # bash truncates at null byte in function arguments, so validate_token
    # receives only "abc" which would pass. Use printf to preserve the null.
    skip "bash truncates null bytes in function arguments"
}
