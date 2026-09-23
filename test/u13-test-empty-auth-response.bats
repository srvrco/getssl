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


# Tests for fix: "json was blank" token validation failure
# When AuthLinkResponse[dn] is empty (e.g. because the ACME server's authorization link didn't match any domain in create_order),
# then json_get returns "json was blank" and validate_token returns error_exit (as the token contains a space which is invalid)

@test "fulfill_challenges: returns 1 with empty AuthLinkResponse[0] instead of erroring in validate_token" {
    alldomains=("example.com")
    AuthLinkResponse=()   # AuthLinkResponse[0] is unset -> empty string
    AuthLinkResponseHeader=()
    USE_SINGLE_ACL="true"
    ACL=("/tmp/acl")
    VALIDATE_VIA_DNS="false"
    DOMAIN="example.com"

    run fulfill_challenges

    # fulfill_challenges should return 1 triggering the retry loop
    assert_failure
    [ "$status" -eq 1 ]

    # Check that validate_token didn't return an error
    refute_output --partial "Invalid token"
}


@test "fulfill_challenges: outputs meaningful log statement when AuthLinkResponse[0] is empty" {
    alldomains=("example.com")
    AuthLinkResponse=()
    AuthLinkResponseHeader=()
    USE_SINGLE_ACL="true"
    ACL=("/tmp/acl")
    VALIDATE_VIA_DNS="false"
    DOMAIN="example.com"

    run fulfill_challenges

    assert_output --partial "Authorization response is empty"
}


@test "fulfill_challenges: returns 1 for second domain too when AuthLinkResponse[1] is empty" {
    alldomains=("example.com" "example.org")
    AuthLinkResponse=()
    AuthLinkResponseHeader=()
    USE_SINGLE_ACL="true"
    ACL=("/tmp/acl")
    VALIDATE_VIA_DNS="false"
    DOMAIN="example.com"
    # AuthLinkResponse[0] is set (previously validated), but [1] is empty
    AuthLinkResponse[0]='{"identifier":{"type":"dns","value":"example.com"},"status":"valid","challenges":[{"type":"dns-01","token":"valid-token"}]}'

    run fulfill_challenges

    # Should fail on domain index 1
    assert_failure
    [ "$status" -eq 1 ]

    refute_output --partial "Invalid token"
    assert_output --partial "Authorization response is empty"
}


@test "fulfill_challenges: does NOT trigger the empty-response guard when AuthLinkResponse is valid" {
    alldomains=("example.com")
    AuthLinkResponse=()
    AuthLinkResponseHeader=()
    AuthLinkResponse[0]='{"identifier":{"type":"dns","value":"example.com"},"status":"valid","challenges":[{"type":"dns-01","token":"valid-token"}]}'
    USE_SINGLE_ACL="true"
    ACL=("/tmp/acl")
    VALIDATE_VIA_DNS="false"
    DOMAIN="example.com"

    # With a valid (already-validated) response, fulfill_challenges returns 0
    # (the domain is skipped with "already validated")
    run fulfill_challenges
    assert_success

    # And the empty-response guard must not have fired
    refute_output --partial "Authorization response is empty"
}


@test "fulfill_challenges: empty AuthLinkResponse does not error with VALIDATE_VIA_DNS=true" {
    # Replicate what I think caused the bug reported in #911 with dns-01 validation 
    alldomains=("example.com")
    AuthLinkResponse=()
    AuthLinkResponseHeader=()
    USE_SINGLE_ACL="true"
    ACL=("/tmp/acl")
    VALIDATE_VIA_DNS="true"
    DOMAIN="example.com"

    run fulfill_challenges

    assert_failure
    [ "$status" -eq 1 ]

    # Must not see the "Invalid token: contains characters outside base64url alphabet" error
    refute_output --partial "Invalid token"

    # Must see the helpful diagnostic
    assert_output --partial "Authorization response is empty"
}


@test "fulfill_challenges: empty AuthLinkResponse does not error for http-01 flow" {
    # Same as above but for the http-01 challenge branch
    alldomains=("example.com")
    AuthLinkResponse=()
    AuthLinkResponseHeader=()
    USE_SINGLE_ACL="true"
    ACL=("/tmp/acl")
    VALIDATE_VIA_DNS="false"
    DOMAIN="example.com"

    run fulfill_challenges

    assert_failure
    [ "$status" -eq 1 ]

    # Must not see the "Invalid token" error
    refute_output --partial "Invalid token"
}
