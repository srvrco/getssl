#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'

# CA with a unified directory (both ACME V1 and V2 at the same URI)
CA="https://api.test4.buypass.no/acme"

# This is run for every test
setup() {
    [ ! -f $BATS_RUN_TMPDIR/failed.skip ] || skip "skipping tests after first failure"

    . /getssl/getssl --source

    requires curl
    _NOMETER="--silent"

    _USE_DEBUG=1
}


teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch $BATS_RUN_TMPDIR/failed.skip
}


@test "Check that API V2 is selected in a unified ACME directory." {
    obtain_ca_resource_locations

    [ "$API" -eq 2 ]
}
