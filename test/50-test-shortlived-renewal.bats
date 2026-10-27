#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# Certificates are renewed once a third of the certificate lifetime remains.
# Pebble's "shortlived" profile issues certificates valid for 6 days, so they
# are renewed 2 days before expiry.  A hardcoded 30 day RENEW_ALLOW would renew
# them on every run, which is what these tests guard against.

setup() {
    [ ! -f "$BATS_RUN_TMPDIR/failed.skip" ] || skip "skipping tests after first failure"
}


teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch "$BATS_RUN_TMPDIR/failed.skip"
}


setup_file() {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal Pebble test"
    fi
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
}


teardown_file() {
    cleanup_environment
}


# Check that a certificate expires between $2 and $3 days from now
check_certificate_lifetime() {
    local cert=$1 min_days=$2 max_days=$3

    # openssl -checkend returns 0 if the certificate is still valid in N seconds
    run openssl x509 -in "$cert" -noout -checkend $(( min_days * 24 * 60 * 60 ))
    [ "$status" -eq 0 ]
    run openssl x509 -in "$cert" -noout -checkend $(( max_days * 24 * 60 * 60 ))
    [ "$status" -ne 0 ]
}


@test "short lived profile issues a certificate valid for about 6 days" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    # shellcheck disable=SC2034
    CONFIG_FILE="getssl-http01-shortlived.cfg"
    setup_environment
    init_getssl
    create_certificate
    assert_success
    check_output_for_errors

    CERT="${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt"
    check_certificate_lifetime "$CERT" 5 7
}


@test "short lived certificate isn't renewed while a third of its lifetime remains" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    # shellcheck disable=SC2034
    CONFIG_FILE="getssl-http01-shortlived.cfg"
    setup_environment
    init_getssl
    create_certificate
    assert_success
    check_output_for_errors

    CERT="${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt"
    ORIGINAL_SERIAL=$(openssl x509 -in "$CERT" -noout -serial)

    create_certificate
    assert_success
    check_output_for_errors

    # a third of the 6 day lifetime is 2 days
    assert_line --partial 'certificate is valid for more than 2 days'
    refute_line --partial 'certificate needs renewal'

    UPDATED_SERIAL=$(openssl x509 -in "$CERT" -noout -serial)
    if [[ "$ORIGINAL_SERIAL" != "$UPDATED_SERIAL" ]]; then
        echo "# ORIGINAL_SERIAL=$ORIGINAL_SERIAL"
        echo "# UPDATED_SERIAL =$UPDATED_SERIAL"
    fi
    [[ "$ORIGINAL_SERIAL" = "$UPDATED_SERIAL" ]]
}


@test "short lived certificate is renewed when RENEW_ALLOW has been reached" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    # shellcheck disable=SC2034
    CONFIG_FILE="getssl-http01-shortlived.cfg"
    setup_environment
    init_getssl
    create_certificate
    assert_success
    check_output_for_errors

    CERT="${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt"
    ORIGINAL_SERIAL=$(openssl x509 -in "$CERT" -noout -serial)

    # more than the 6 days which remain on a short lived certificate
    cat <<- EOF > "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg"
RENEW_ALLOW=7
EOF

    create_certificate
    assert_success
    check_output_for_errors

    refute_line --partial 'certificate is valid for more than'
    UPDATED_SERIAL=$(openssl x509 -in "$CERT" -noout -serial)
    if [[ "$ORIGINAL_SERIAL" = "$UPDATED_SERIAL" ]]; then
        echo "# ORIGINAL_SERIAL=$ORIGINAL_SERIAL"
        echo "# UPDATED_SERIAL =$UPDATED_SERIAL"
    fi
    [[ "$ORIGINAL_SERIAL" != "$UPDATED_SERIAL" ]]

    # the renewed certificate must also use the short lived profile
    check_certificate_lifetime "$CERT" 5 7
}


@test "90 day certificate is renewed 30 days before expiry" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    # shellcheck disable=SC2034
    CONFIG_FILE="getssl-http01-shortlived.cfg"
    setup_environment
    init_getssl

    # issue a certificate with the default 90 day lifetime
    cat <<- EOF > "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg"
PROFILE="default"
EOF

    create_certificate
    assert_success
    check_output_for_errors

    CERT="${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt"
    check_certificate_lifetime "$CERT" 80 95
    ORIGINAL_SERIAL=$(openssl x509 -in "$CERT" -noout -serial)

    create_certificate
    assert_success
    check_output_for_errors

    # a third of the 90 day lifetime is 30 days
    assert_line --partial 'certificate is valid for more than 30 days'
    refute_line --partial 'certificate needs renewal'

    UPDATED_SERIAL=$(openssl x509 -in "$CERT" -noout -serial)
    if [[ "$ORIGINAL_SERIAL" != "$UPDATED_SERIAL" ]]; then
        echo "# ORIGINAL_SERIAL=$ORIGINAL_SERIAL"
        echo "# UPDATED_SERIAL =$UPDATED_SERIAL"
    fi
    [[ "$ORIGINAL_SERIAL" = "$UPDATED_SERIAL" ]]
}


@test "ARI is used to decide renewal for short lived certificates" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    # shellcheck disable=SC2034
    CONFIG_FILE="getssl-http01-shortlived.cfg"
    setup_environment
    init_getssl
    create_certificate
    assert_success
    check_output_for_errors

    CERT="${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/${GETSSL_CMD_HOST}.crt"
    ORIGINAL_SERIAL=$(openssl x509 -in "$CERT" -noout -serial)

    cat <<- EOF > "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl_test_specific.cfg"
ARI_ENABLE="true"
EOF

    create_certificate
    assert_success
    check_output_for_errors

    # Pebble's ARI renewal window for a 6 day certificate starts after 3 days
    assert_line --partial 'certificate has not yet reached ARI renewal window'
    refute_line --partial 'certificate needs renewal'

    UPDATED_SERIAL=$(openssl x509 -in "$CERT" -noout -serial)
    if [[ "$ORIGINAL_SERIAL" != "$UPDATED_SERIAL" ]]; then
        echo "# ORIGINAL_SERIAL=$ORIGINAL_SERIAL"
        echo "# UPDATED_SERIAL =$UPDATED_SERIAL"
    fi
    [[ "$ORIGINAL_SERIAL" = "$UPDATED_SERIAL" ]]
}
