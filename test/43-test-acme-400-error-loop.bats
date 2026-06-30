#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'

# PR #902
# This is to test for regressions to a fix to send_signed_request()
# If there is a malformed request to the server which returns an error code != 5* and the response includes the message "bad:Nonce" 
# then getssl enters an infinite loop.  This should only happen when testing code changes, but fixing just in case
 
teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch $BATS_RUN_TMPDIR/failed.skip
    rm /getssl/test/curl
    rm /tmp/mock.out
}

setup() {
    [ ! -f $BATS_RUN_TMPDIR/failed.skip ] || skip "skipping tests after first failure"

    # Create mock curl for ACME POST requests (testing loop_limit guard; see PR #902).
    # Activates against the /getssl/test PATH already configured by test_helper.bash.
    cat << 'MOCK_CURL' > /getssl/test/curl
#!/usr/bin/env bash
# Only mock if explicitly enabled AND it's a POST request (ACME requests)
echo "# Inside mock curl" >> /tmp/mock.out
if [[ "$GETSSL_MOCK_500" == "1" ]] && [[ "$*" == *"-X POST"* ]]; then
  DUMP_HEADER=""
  # Parse arguments without destroying $@ so we can still passthrough if needed
  args=("$@")
  for (( i=0; i<${#args[@]}; i++ )); do
    case "${args[$i]}" in
      --dump-header)
        DUMP_HEADER="${args[$((i+1))]}"
        break
        ;;
    esac
  done

  if [[ -n "$DUMP_HEADER" ]]; then
    echo "HTTP/1.1 400 Internal Server Error" > "$DUMP_HEADER"
    echo "Replay-Nonce: mock-nonce-123" >> "$DUMP_HEADER"
    echo "Content-Type: application/json" >> "$DUMP_HEADER"
    echo "" >> "$DUMP_HEADER"
  fi
  echo '{"type": "urn:ietf:params:acme:error:badNonce:serverInternal", "detail": "Mock ACME server 400 error for testing loop_limit", "status": 400}'
  exit 0
else
  # Passthrough to real curl for HEAD requests (nonce fetch), GETs, etc.
  export PATH="${PATH#/getssl/test:}"
  REAL_CURL=$(command -v curl)
  exec "$REAL_CURL" "$@"
fi
MOCK_CURL
    chmod +x /getssl/test/curl
}

setup_file() {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal ARI/Pebble test"
    fi

    # Timeout the test after 120 seconds to catch any regression where the loop_limit
    # guard fails and an infinite loop occurs. With the smart mocks, this test should
    # naturally complete in < 1 second.
    # Using 1200 instead of 120 as sleep is overridden in testing to 10% of original value
    export BATS_TEST_TIMEOUT=1200

    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
}

@test "getssl should exit with error after 5 retries on persistent 400 error" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    CONFIG_FILE="getssl-http01.cfg"
    setup_environment

    # Normal initialization uses real curl (mock is inactive)
    init_getssl

    # 4. Enable the 500 mock ONLY for the certificate creation step
    export GETSSL_MOCK_500=1

    # We expect this to fail because of the persistent 500 errors
    #run /getssl/getssl -U -d "$GETSSL_CMD_HOST"
    create_certificate

    unset GETSSL_MOCK_500

    # 5. Assertions
    assert_failure

    # Verify it attempted to retry (checks the loop is actually executing)
    assert_output --regexp "loop_limit = 1"

    # Verify the loop_limit guard triggered and aborted cleanly instead of looping infinitely
    assert_output --regexp "400 error from ACME server"
}
