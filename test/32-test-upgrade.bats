#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt
    run git clone https://github.com/srvrco/getssl.git "$INSTALL_DIR/upgrade-getssl"
    # Don't do version arithmetics any longer, look what there really is
    cd "$INSTALL_DIR/upgrade-getssl"
    CURRENT_VERSION=$(git tag -l|grep -e '^v'|tail -1|cut -b2-)
    PREVIOUS_VERSION=$(git tag -l|grep -e '^v'|tail -2|head -1|cut -b2-)
    # The version in the file, which we will overwrite
    FILE_VERSION=$(awk -F'"' '/^VERSION=/{print $2}' "$CODE_DIR/getssl")
}


teardown() {
    rm -r "$INSTALL_DIR/upgrade-getssl"
}


@test "Test that we are told that a newer version is available" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    cd "$INSTALL_DIR/upgrade-getssl"
    git checkout tags/v${PREVIOUS_VERSION}

    CONFIG_FILE="getssl-http01.cfg"
    setup_environment
    init_getssl
    cp "${CODE_DIR}/test/test-config/${CONFIG_FILE}" "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl.cfg"
    # Overwrite checked out getssl-script with copy of new one, 
    # but write the previous version into the copy
    # Note that this way we actually downgrade getssl, but we are testing
    # the upgrading of the version in development
    cp "$CODE_DIR/getssl" "$INSTALL_DIR/upgrade-getssl/"
    sed -i -e "s/VERSION=\"${FILE_VERSION}\"/VERSION=\"${PREVIOUS_VERSION}\"/" "$INSTALL_DIR/upgrade-getssl/getssl" 
    run "$INSTALL_DIR/upgrade-getssl/getssl" --check-config ${GETSSL_CMD_HOST}
    assert_success
    #assert_line "Updated getssl from v${PREVIOUS_VERSION} to v${CURRENT_VERSION}"
    assert_line "A more recent version (v${CURRENT_VERSION}) of getssl is available, please update"
    check_output_for_errors
}


@test "Test that we can upgrade to the newer version" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    cd "$INSTALL_DIR/upgrade-getssl"
    git checkout tags/v${CURRENT_VERSION}

    CONFIG_FILE="getssl-http01.cfg"
    setup_environment
    init_getssl
    cp "${CODE_DIR}/test/test-config/${CONFIG_FILE}" "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl.cfg"
    # Overwrite checked out getssl-script with copy of new one, 
    # but write the previous version into the copy
    # Note that this way we actually downgrade getssl, but we are testing
    # the upgrading of the version in development
    cp "$CODE_DIR/getssl" "$INSTALL_DIR/upgrade-getssl/"
    sed -i -e "s/VERSION=\"${FILE_VERSION}\"/VERSION=\"${PREVIOUS_VERSION}\"/" "$INSTALL_DIR/upgrade-getssl/getssl" 
    run "$INSTALL_DIR/upgrade-getssl/getssl" --check-config --upgrade ${GETSSL_CMD_HOST}
    assert_success
    assert_line "Updated getssl from v${PREVIOUS_VERSION} to v${CURRENT_VERSION}"
    check_output_for_errors
}


@test "Test that we can upgrade to the newer version when invoking as \"bash ./getssl\"" {
    # Note that `bash getssl` will fail if the CWD isn't in the PATH and an upgrade occurs
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    cd "$INSTALL_DIR/upgrade-getssl"
    git checkout tags/v${PREVIOUS_VERSION}

    CONFIG_FILE="getssl-http01.cfg"
    setup_environment
    init_getssl
    cp "${CODE_DIR}/test/test-config/${CONFIG_FILE}" "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl.cfg"
    # Overwrite checked out getssl-script with copy of new one, 
    # but write the previous version into the copy
    # Note that this way we actually downgrade getssl, but we are testing
    # the upgrading of the version in development
    cp "$CODE_DIR/getssl" "$INSTALL_DIR/upgrade-getssl/"
    sed -i -e "s/VERSION=\"${FILE_VERSION}\"/VERSION=\"${PREVIOUS_VERSION}\"/" "$INSTALL_DIR/upgrade-getssl/getssl" 
    run bash ./getssl --check-config --upgrade ${GETSSL_CMD_HOST}
    assert_success
    assert_line "Updated getssl from v${PREVIOUS_VERSION} to v${CURRENT_VERSION}"
    check_output_for_errors
}
