#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


@test "Check mktemp -t getssl.XXXXXX works on all platforms" {
    run mktemp -t getssl.XXXXXX
    assert_success
}
