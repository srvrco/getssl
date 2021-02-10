#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt

    # Turn off warning about detached head
    git config --global advice.detachedHead false
    run git clone https://github.com/srvrco/getssl.git "$INSTALL_DIR/upgrade-getssl"

    # Don't do version arithmetics any longer, look what was the previous version by getting the last
    # line (starting with v) and the one before that from the list of tags.
    cd "$INSTALL_DIR/upgrade-getssl"

    # This sets CURRENT_TAG and PREVIOUS_TAG bash variables
    eval $(git tag -l | awk 'BEGIN {cur="?.??"};/^v/{prv=cur;cur=substr($1,2)};END{ printf("CURRENT_TAG=\"%s\";PREVIOUS_TAG=\"%s\"\n",cur,prv)}')

    # The version in the file, which we will overwrite
    FILE_VERSION=$(awk -F'"' '/^VERSION=/{print $2}' "$CODE_DIR/getssl")
    # If FILE_VERSION > CURRENT_TAG then either we are testing a push to master or the last version wasn't released
}


teardown() {
    rm -r "$INSTALL_DIR/upgrade-getssl"
}


@test "Test that we are told that a newer version is available" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    cd "$INSTALL_DIR/upgrade-getssl"
    git checkout tags/v${PREVIOUS_TAG}

    CONFIG_FILE="getssl-http01.cfg"
    setup_environment
    init_getssl
    cp "${CODE_DIR}/test/test-config/${CONFIG_FILE}" "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl.cfg"

    # Overwrite checked out getssl-script with copy of new one, but write the previous version into the copy
    # Note that this way we mock downgrading getssl and are testing the upgrading of the version in development
    cp "$CODE_DIR/getssl" "$INSTALL_DIR/upgrade-getssl/"
    sed -i -e "s/VERSION=\"${FILE_VERSION}\"/VERSION=\"${PREVIOUS_TAG}\"/" "$INSTALL_DIR/upgrade-getssl/getssl"

    run "$INSTALL_DIR/upgrade-getssl/getssl" --check-config ${GETSSL_CMD_HOST}
    assert_success

    # Check for current tag or file version otherwise push to master fails on a new version (or if the tag hasn't been updated)
    assert_line --regexp "A more recent version \(v(${CURRENT_TAG}|${FILE_VERSION})\) of getssl is available, please update"
    check_output_for_errors
}


@test "Test that we can upgrade to the newer version" {
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    cd "$INSTALL_DIR/upgrade-getssl"
    git checkout tags/v${CURRENT_TAG}

    CONFIG_FILE="getssl-http01.cfg"
    setup_environment
    init_getssl
    cp "${CODE_DIR}/test/test-config/${CONFIG_FILE}" "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl.cfg"

    # Overwrite checked out getssl-script with copy of new one, but write the previous version into the copy
    # Note that this way we mock downgrading getssl and are testing the upgrading of the version in development
    cp "$CODE_DIR/getssl" "$INSTALL_DIR/upgrade-getssl/"
    sed -i -e "s/VERSION=\"${FILE_VERSION}\"/VERSION=\"${PREVIOUS_TAG}\"/" "$INSTALL_DIR/upgrade-getssl/getssl"

    run "$INSTALL_DIR/upgrade-getssl/getssl" --check-config --upgrade ${GETSSL_CMD_HOST}
    assert_success

    # Check for current tag or file version otherwise push to master fails on a new version (or if the tag hasn't been updated)
    assert_line --regexp "Updated getssl from v${PREVIOUS_TAG} to v(${CURRENT_TAG}|${FILE_VERSION})"
}


@test "Test that we can upgrade to the newer version when invoking as \"bash ./getssl\"" {
    # Note that `bash getssl` will fail if the CWD isn't in the PATH and an upgrade occurs
    if [ -n "$STAGING" ]; then
        skip "Using staging server, skipping internal test"
    fi

    cd "$INSTALL_DIR/upgrade-getssl"
    git checkout tags/v${PREVIOUS_TAG}

    CONFIG_FILE="getssl-http01.cfg"
    setup_environment
    init_getssl
    cp "${CODE_DIR}/test/test-config/${CONFIG_FILE}" "${INSTALL_DIR}/.getssl/${GETSSL_CMD_HOST}/getssl.cfg"

    # Overwrite checked out getssl-script with copy of new one, but write the previous version into the copy
    # Note that this way we mock downgrading getssl and are testing the upgrading of the version in development
    cp "$CODE_DIR/getssl" "$INSTALL_DIR/upgrade-getssl/"
    sed -i -e "s/VERSION=\"${FILE_VERSION}\"/VERSION=\"${PREVIOUS_TAG}\"/" "$INSTALL_DIR/upgrade-getssl/getssl"

    run bash ./getssl --check-config --upgrade ${GETSSL_CMD_HOST}
    assert_success

    # Check for current tag or file version otherwise push to master fails on a new version (or if the tag hasn't been updated)
    assert_line --regexp "Updated getssl from v${PREVIOUS_TAG} to v(${CURRENT_TAG}|${FILE_VERSION})"
}
