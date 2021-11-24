#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'

LIMIT_API="https://api.github.com/rate_limit"

# Quota generally shouldn't be an issue - except for tests
# Rate limits are per-IP address
check_github_quota() {
  local need remaining reset limits now
  need="$1"
  while true ; do
    limits="$(curl ${_NOMETER:---silent} --user-agent "$CURL_USERAGENT" -H 'Accept: application/vnd.github.v3+json' "$LIMIT_API" | sed -e's/\("[^:]*": *\("[^""]*",\|[^,]*[,}]\)\)/\r\n\1/g' | sed -ne'/"core":/,/}/p')"
    errcode=$?
    if [[ $errcode -eq 60 ]]; then
      error_exit "curl needs updating, your version does not support SNI (multiple SSL domains on a single IP)"
    elif [[ $errcode -gt 0 ]]; then
      error_exit "curl error checking releases: $errcode"
    fi
    limits="$(sed -e's/^ *//g' <<<"${limits}")"
    remaining="$(sed -e'/^"remaining": *[0-9]/!d;s/^"remaining": *\([0-9][0-9]*\).*$/\1/' <<<"${limits}")"
    reset="$(sed -e'/^"reset": *[0-9]/!d;s/^"reset": *\([0-9][0-9]*\).*$/\1/' <<<"${limits}")"
    if [[ "$remaining" -ge "$need" ]] ; then return 0 ; fi
    limit="$(sed -e'/^"limit": *[0-9]/!d;s/^"limit": *\([0-9][0-9]*\).*$/\1/' <<<"${limits}")"
    if [[ "$limit" -lt "$need" ]] ; then
      error_exit "GitHub API request $need exceeds limit $limit"
    fi
    now="$(date +%s)"
    while [[ "$now" -lt "$reset" ]] ; do
      info "sleeping $(( "$reset" - "$now" )) seconds for GitHub quota"
      sleep "$(( "$reset" - "$now" ))"
      now="$(date +%s)"
   done
  done
}


setup_file() {
    if [ -f $BATS_RUN_TMPDIR/failed.skip ]; then
        echo "# Skipping setup due to previous test failure" >&3
        return 0
    fi
    local n
    # Not every tag reflects a stable release.  Ask GitHub for the releases & identify the last two.
    # This is sorted by creation date of the release tag, not the publication date.  This matches
    # GitHub's releases/latest, which is how getssl determines what's available.
    # This is expensive, so do it only once

    . "${CODE_DIR}/getssl" -U --source
    check_github_quota 7
    export RELEASES="$(mktemp 2>/dev/null || mktemp -t getssl.XXXXXX)"
    if [ -z "$RELEASES" ]; then
        echo "# mktemp failed" >&3
        return 1
    fi
    if ! curl ${_NOMETER:---silent} --user-agent "$CURL_USERAGENT" \
        -H 'Accept: application/vnd.github.v3+json' "${RELEASE_API%/latest}" | \
        jq 'map(select((.draft or .prerelease)|not))|sort_by(.created_at)|reverse' >"$RELEASES" ; then
        errcode="$?"
        echo "# Failed to download release information from ${RELEASE_API%/latest} $errcode" >&3
        return "$errcode"
    fi
    n="$(jq '.|length' <$RELEASES)"
    if [[ "$n" < 2 ]]; then
        echo "# Fewer than 2 ($n) stable releases detected in ${RELEASE_API%/latest}, can not run upgrade tests" >&3
        return 0
    fi
    CURRENT_TAG="$(jq -r '.[0].tag_name' <"$RELEASES")"
    export CURRENT_TAG="${CURRENT_TAG:1}"
    PREVIOUS_TAG="$(jq -r '.[1].tag_name' <"$RELEASES")"
    export PREVIOUS_TAG="${PREVIOUS_TAG:1}"
}

teardown_file() {
    [ -n "$RELEASES" ] && rm -f "$RELEASES"
    true
}

# This is run for every test
setup() {
    [ ! -f $BATS_RUN_TMPDIR/failed.skip ] || skip "skipping tests after first failure"
    [ -z "$PREVIOUS_TAG" ] && skip "Skipping upgrade test because no previous release detected"

    export CURL_CA_BUNDLE=/root/pebble-ca-bundle.crt

    # Turn off warning about detached head
    git config --global advice.detachedHead false
    if [[ -n "${GITHUB_REPOSITORY}" ]] ; then
      _REPO="https://github.com/${GITHUB_REPOSITORY}.git"
    else
      _REPO="https://github.com/srvrco/getssl.git"
    fi
    run git clone "${_REPO}" "$INSTALL_DIR/upgrade-getssl"


    cd "$INSTALL_DIR/upgrade-getssl"

    # The version in the file, which we will overwrite
    FILE_VERSION=$(awk -F'"' '/^VERSION=/{print $2}' "$CODE_DIR/getssl")
    # If FILE_VERSION > CURRENT_TAG then either we are testing a push to master or the last version wasn't released
}


teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch $BATS_RUN_TMPDIR/failed.skip
    [ -d "$INSTALL_DIR/upgrade-getssl" ] && rm -r "$INSTALL_DIR/upgrade-getssl"
    true
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

    run "$INSTALL_DIR/upgrade-getssl/getssl" -d --check-config ${GETSSL_CMD_HOST}
    assert_success

    # Check for current tag or file version otherwise push to master fails on a new version (or if the tag hasn't been updated)
    assert_line --regexp "A more recent version \(v(${CURRENT_TAG}|${FILE_VERSION})\) than .* of getssl is available, please update"
    # output can contain "error" in release description
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

    run "$INSTALL_DIR/upgrade-getssl/getssl" -d --check-config --upgrade ${GETSSL_CMD_HOST}
    assert_success

    # Check for current tag or file version otherwise push to master fails on a new version (or if the tag hasn't been updated)
    assert_line --regexp "Installed v(${CURRENT_TAG}|${FILE_VERSION}), restarting"
    assert_line --partial "Configuration check successful"
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

    run bash ./getssl -d --check-config --upgrade ${GETSSL_CMD_HOST}
    assert_success

    # Check for current tag or file version otherwise push to master fails on a new version (or if the tag hasn't been updated)
    assert_line --regexp "Installed v(${CURRENT_TAG}|${FILE_VERSION}), restarting"
}
