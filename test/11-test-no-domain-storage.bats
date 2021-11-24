#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


setup() {
    [ ! -f $BATS_RUN_TMPDIR/failed.skip ] || skip "skipping tests after first failure"
}
teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch $BATS_RUN_TMPDIR/failed.skip
}

@test "Check that if domain storage isn't set getssl doesn't try to delete /tmp" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi
    CONFIG_FILE="getssl-http01-no-domain-storage.cfg"
    setup_environment
    mkdir ${INSTALL_DIR}/.getssl
    cp "${CODE_DIR}/test/test-config/${CONFIG_FILE}" "${INSTALL_DIR}/.getssl/getssl.cfg"
    run ${CODE_DIR}/getssl -U -d -a
    assert_success
    check_output_for_errors
    assert_line --partial 'Not going to delete TEMP_DIR ///tmp as it appears to be /tmp'
}
