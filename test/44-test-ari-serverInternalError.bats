#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'

# This test verifies that getssl handles the ACME server internal error
# "could not find an order for the given certificate: could not find order resulting
# in the given certificate serial number" when attempting ARI renewal.
# The fix should detect this error, clear the _REPLACES field, and retry without it.

teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch $BATS_RUN_TMPDIR/failed.skip
}

setup() {
    [ ! -f $BATS_RUN_TMPDIR/failed.skip ] || skip "skipping tests after first failure"

    # 1. Create smart mock curl
    cat << 'MOCK_CURL' > /getssl/test/curl
#!/usr/bin/env bash
# Only mock if explicitly enabled AND it's a POST request (ACME requests)
if [[ "$GETSSL_MOCK_ARI_ERROR" == "1" ]] && [[ "$*" == *"-X POST"* ]]; then
  DUMP_HEADER=""
  DATA_PAYLOAD=""
  # Parse arguments without destroying $@ so we can still passthrough if needed
  args=("$@")
  for (( i=0; i<${#args[@]}; i++ )); do
    case "${args[$i]}" in
      --dump-header)
        DUMP_HEADER="${args[$((i+1))]}"
        ;;
      --data)
        DATA_PAYLOAD="${args[$((i+1))]}"
        ;;
    esac
  done

  # Check if payload contains "replaces" (base64-encoded in the request)
  # Decode the payload to check for "replaces" field
  # The payload is URL-safe base64 encoded JSON in the "payload" field of the body
  has_replaces=0
  if [[ -n "$DATA_PAYLOAD" ]]; then
    # Extract the payload field from the JWS body (it's base64url encoded)
    encoded_payload=$(echo "$DATA_PAYLOAD" | jq -r '.payload // empty' 2>/dev/null)
    if [[ -n "$encoded_payload" ]]; then
      # Decode URL-safe base64 to regular base64, then decode
      decoded=$(echo "$encoded_payload" | tr '_-' '/+' | base64 -d 2>/dev/null)
      if [[ "$decoded" == *'"replaces"'* ]]; then
        has_replaces=1
      fi
    fi
  fi

  # Return error if payload contains "replaces"
  # This simulates the pebble server error when it can't find the certificate
  if [[ $has_replaces -eq 1 ]]; then
    if [[ -n "$DUMP_HEADER" ]]; then
      echo "HTTP/1.1 500 Internal Server Error" > "$DUMP_HEADER"
      echo "Cache-Control: public, max-age=0, no-cache" >> "$DUMP_HEADER"
      echo "Content-Type: application/problem+json; charset=utf-8" >> "$DUMP_HEADER"
      echo "Replay-Nonce: mock-nonce-ari-error" >> "$DUMP_HEADER"
      echo "" >> "$DUMP_HEADER"
    fi
    echo '{"type": "urn:ietf:params:acme:error:serverInternal", "detail": "could not find an order for the given certificate: could not find order resulting in the given certificate serial number", "status": 500}'
    exit 0
  else
    # Payload does NOT contain "replaces", let it pass through to real curl
    export PATH="${PATH#/getssl/test:}"
    REAL_CURL=$(command -v curl)
    exec "$REAL_CURL" "$@"
  fi
else
  # Passthrough to real curl for HEAD requests (nonce fetch), GETs, etc.
  export PATH="${PATH#/getssl/test:}"
  REAL_CURL=$(command -v curl)
  exec "$REAL_CURL" "$@"
fi
MOCK_CURL
    chmod +x /getssl/test/curl

    # 2. Create smart mock sleep (only intercepts the exact 30s loop delay)
    cat << 'MOCK_SLEEP' > /getssl/test/sleep
#!/usr/bin/env bash
if [[ "$1" == "30" ]]; then
  exit 0
else
  export PATH="${PATH#/getssl/test:}"
  REAL_SLEEP=$(command -v sleep)
  exec "$REAL_SLEEP" "$@"
fi
MOCK_SLEEP
    chmod +x /getssl/test/sleep

    # 3. Prepend test directory to PATH to activate mocks
    export PATH="/getssl/test:$PATH"
}

setup_file() {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal ARI/Pebble test"
    fi

    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
}


@test "ARI renewal succeeds after server internal error on replaces field" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    CONFIG_FILE="getssl-http01.cfg"
    setup_environment
    init_getssl
    create_certificate
    assert_success
    check_output_for_errors

    CERT=${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt
    ORIGINAL_SERIAL=$(openssl x509 -in "$CERT" -noout -serial)

    # Configure ARI window as open so getssl will attempt ARI renewal
    configure_pebble_ari_window open "$CERT"

    # Enable the mock that returns the "could not find order" error
    export GETSSL_MOCK_ARI_ERROR=1

    # Run getssl - it should:
    # 1. Attempt ARI renewal with "replaces" field
    # 2. Get "could not find order" error from mock
    # 3. Clear _REPLACES and retry
    # 4. Succeed on retry without "replaces"
    run "${CODE_DIR}/getssl" -U -d "$GETSSL_CMD_HOST"

    unset GETSSL_MOCK_ARI_ERROR

    assert_success
    # Verify we got the mock error (proves the mock was triggered)
    assert_output --partial "could not find an order for the given certificate"
    # Verify ARI was attempted
    assert_output --partial "Within ARI renewal window, using ARI"
    # Verify the fix was applied (replaces field was cleared)
    assert_output --partial "clearing"

    # Don't use check_output_for_errors as the error message contains "error"
    # which will fail the assertion. Instead, check for specific bad outcomes.
    refute_output --regexp '[Ff][Aa][Ii][Ll][Ee][Dd]'
    refute_output --regexp '[^_][Ww][Aa][Rr][Nn][Ii][Nn][Gg]'
    refute_line --partial 'command not found'

    # Verify the certificate was actually renewed (serial changed)
    UPDATED_SERIAL=$(openssl x509 -in "$CERT" -noout -serial)
    [[ "$ORIGINAL_SERIAL" != "$UPDATED_SERIAL" ]]
}
