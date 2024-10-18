#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    [ ! -f $BATS_RUN_TMPDIR/failed.skip ] || skip "skipping tests after first failure"

    . /getssl/getssl --source
#    find_dns_utils
    _USE_DEBUG=1
}


teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch $BATS_RUN_TMPDIR/failed.skip
}


@test "Check obtain_ca_resource_locations for LetsEncrypt (uses newlines)" {
    # LetsEncrypt CA splits the directory with comma then newline
    CA="https://acme-staging-v02.api.letsencrypt.org/directory"
    obtain_ca_resource_locations

    assert_equal $API 2
    assert_not_equal $URL_newAccount $URL_newNonce
    assert_not_equal $URL_newNonce $URL_newOrder
    assert_not_equal $URL_newOrder $URL_revole
}


@test "Check obtain_ca_resource_locations for Sectigo (no newlines)" {
    # Sectigo CA splits the directory with commas
    CA="https://acme.enterprise.sectigo.com"
    obtain_ca_resource_locations

    assert_equal $API 2
    assert_not_equal $URL_newAccount $URL_newNonce
    assert_not_equal $URL_newNonce $URL_newOrder
    assert_not_equal $URL_newOrder $URL_revole
}


@test "Check obtain_ca_resource_locations for BuyPass (no newlines)" {
    # BuyPass CA splits the directory with commas
    CA="https://api.test4.buypass.no/acme"
    obtain_ca_resource_locations

    assert_equal $API 2
    assert_not_equal $URL_newAccount $URL_newNonce
    assert_not_equal $URL_newNonce $URL_newOrder
    assert_not_equal $URL_newOrder $URL_revole
}
