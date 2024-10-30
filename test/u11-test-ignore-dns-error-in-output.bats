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

# First sample text where we don't want check_output_for_errors to find an error
output1=(
'send_signed_request:533 code 200'
'send_signed_request:533 response status = invalid'
'check_challenge_completion:1472 *.ubuntu-acmedns-getssl.freeddns.org:Verify error:    "detail": "DNS problem: server failure at resolver looking up CAA for freeddns.org",'
'del_dns_rr:1474 removing DNS RR via command: /getssl/dns_scripts/dns_del_acmedns ubuntu-acmedns-getssl.freeddns.org hEAib3ePU0s8-G3HPmPSa50ZjfdKt0A0qskHyTfBJr8'
'send_signed_request:1215 url https://acme-staging-v02.api.letsencrypt.org/acme/new-order'
'send_signed_request:1215 using KID=https://acme-staging-v02.api.letsencrypt.org/acme/acct/168360453'
'send_signed_request:1215 payload = {"identifiers": [{"type":"dns","value":"*.ubuntu-acmedns-getssl.freeddns.org"}]}'
)

# Second sample text where we don't want check_output_for_errors to find an error
output2=(
'send_signed_request:3553 response {  "identifier": {    "type": "dns",    "value": "ubuntu-acmedns-getssl.freeddns.org"  },  "status": "invalid",  "expires": "2024-10-30T15:24:16Z",  "challenges": [    {      "type": "dns-01",      "url": "https://acme-staging-v02.api.letsencrypt.org/acme/chall-v3/14558038743/zzz8VA",      "status": "invalid",      "validated": "2024-10-23T15:24:18Z",      "error": {        "type": "urn:ietf:params:acme:error:dns",        "detail": "DNS problem: server failure at resolver looking up CAA for freeddns.org",        "status": 400      },      "token": "PyBVfKevM4noXq3fdsFs_0G1BY_o7Nl7eGa6mQw7oJM",      "validationRecord": [        {          "hostname": "ubuntu-acmedns-getssl.freeddns.org"        }      ]    }  ],  "wildcard": true}'
'send_signed_request:3553 code 200'
'send_signed_request:3553 response status = invalid'
'main:0 deactivating domain'
'main:0 deactivating  https://acme-staging-v02.api.letsencrypt.org/acme/authz-v3/14558038743'
'send_signed_request:3557 url https://acme-staging-v02.api.letsencrypt.org/acme/authz-v3/14558038743'
'send_signed_request:3557 using KID=https://acme-staging-v02.api.letsencrypt.org/acme/acct/168360453'
'send_signed_request:3557 payload = {"resource": "authz", "status": "deactivated"}'
)

# Text that should cause check_output_for_errors to find an error
output3=(
'send_signed_request:3553 code 200'
'send_signed_request:3553 response status = error'
'main:0 deactivating domain'
'main:0 deactivating  https://acme-staging-v02.api.letsencrypt.org/acme/authz-v3/14558038743'
'send_signed_request:3557 url https://acme-staging-v02.api.letsencrypt.org/acme/authz-v3/14558038743'
'send_signed_request:3557 using KID=https://acme-staging-v02.api.letsencrypt.org/acme/acct/168360453'
'send_signed_request:3557 payload = {"resource": "authz", "status": "deactivated"}'
)


output_test_text() {
    input_array=("$@")
    printf '%s\n' "${input_array[@]}"
}


@test "Test that 'Verify error...DNS problem'  in first sample output is ignored" {
    # print the known output that used to break the check
    run output_test_text "${output1[@]}"

    # run the check
    check_output_for_errors
}


@test "Test that 'acme:dns:error' in second sample output is ignored" {
    # print the known output that used to break the check
    run output_test_text "${output2[@]}"

    # run the check
    check_output_for_errors
}


@test "Test that generic error in third sample output is NOT ignored" {
    # print sample output that should cause 'check_output_for_errors' to fail a test
    run output_test_text "${output3[@]}"

    # run the function and check the output confirms that it would fail the test
    run check_output_for_errors
    assert_output --partial "-- regular expression should not match output --"
}
