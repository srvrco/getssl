#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
}


@test "Check getssl fails if an old version of awk is installed" {
    CONFIG_FILE="getssl-http01.cfg"
    # Make sure this test only runs on an image running an old version of awk
    awk_version=$(awk -V 2>/dev/null) || true
    if [[ "$awk_version" == "" ]]; then
        setup_environment
        init_getssl
        create_certificate
        assert_failure
        assert_output "getssl: Your version of awk does not work with json_awk (see http://github.com/step-/JSON.awk/issues/6), please install a newer version of mawk or gawk"
    fi
}
