#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch $BATS_RUN_TMPDIR/failed.skip
}

setup() {
    [ ! -f $BATS_RUN_TMPDIR/failed.skip ] || skip "skipping tests after first failure"
    . /getssl/getssl --source
    find_dns_utils
    _USE_DEBUG=1
}


@test "Check create_csr works for multiple domains" {
    # Create a key
    csr_key=$(mktemp -t getssl.key.XXXXXX) || error_exit "mktemp failed"
    csr_file=$(mktemp -t getssl.csr.XXXXXX) || error_exit "mktemp failed"
    SANS="a.getssl.test,b.getssl.test"
    SANLIST="subjectAltName=DNS:${SANS//[, ]/,DNS:}"
    create_key "$ACCOUNT_KEY_TYPE" "$csr_key" "$ACCOUNT_KEY_LENGTH"

    # Create an initial csr
    run create_csr $csr_file $csr_key
    assert_success

    # Check that calling create_csr with the same SANSLIST doesn't re-create the csr
    run create_csr $csr_file $csr_key
    assert_success
    refute_line --partial "does not have the same domains"

    # Check that calling create_csr with a different SANSLIST does re-create the csr
    SANS="a.getssl.test,b.getssl.test,c.getssl.test"
    SANLIST="subjectAltName=DNS:${SANS//[, ]/,DNS:}"
    run create_csr $csr_file $csr_key
    assert_success
    assert_line --partial "does not contain"

    # Check that calling create_csr with the same SANSLIST, but in a different order does not re-create the csr
    SANS="c.getssl.test,a.getssl.test,b.getssl.test"
    SANLIST="subjectAltName=DNS:${SANS//[, ]/,DNS:}"
    run create_csr $csr_file $csr_key
    assert_success
    refute_line --partial "does not contain"

    # Check that removing a domain from the SANSLIST causes the csr to be re-created
    SANS="c.getssl.test,a.getssl.test"
    SANLIST="subjectAltName=DNS:${SANS//[, ]/,DNS:}"
    run create_csr $csr_file $csr_key
    assert_success
    assert_line --partial "does not have the same domains as the config"
}
