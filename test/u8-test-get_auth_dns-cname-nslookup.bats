#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    [ ! -f $BATS_RUN_TMPDIR/failed.skip ] || skip "skipping tests after first failure"
    for app in dig drill host
    do
        if [ -f /usr/bin/${app} ]; then
            mv /usr/bin/${app} /usr/bin/${app}.getssl.bak
        fi
    done

    . /getssl/getssl --source
    find_dns_utils
    _USE_DEBUG=1

    NSLOOKUP_VERSION=$(echo "" | nslookup -version 2>/dev/null | awk -F"[ -]" '{ print $2 }')
    # Version 9.11.3 on Ubuntu -debug doesn't work inside docker in my test env, version 9.16.1 does
    if [[ "${NSLOOKUP_VERSION}" != "Invalid" ]] && check_version "${NSLOOKUP_VERSION}" "9.11.4" ; then
        DNS_CHECK_OPTIONS="$DNS_CHECK_OPTIONS -debug"
    else
        skip "This version of nslookup either doesn't support -debug or it doesn't work in local docker"
    fi
}


teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch $BATS_RUN_TMPDIR/failed.skip
    for app in dig drill host
    do
        if [ -f /usr/bin/${app}.getssl.bak ]; then
            mv /usr/bin/${app}.getssl.bak /usr/bin/${app}
        fi
    done
}


@test "Check get_auth_dns for a CNAME using system DNS and nslookup" {
    PUBLIC_DNS_SERVER=
    AUTH_DNS_SERVER=
    CHECK_ALL_AUTH_DNS="false"
    CHECK_PUBLIC_DNS_SERVER="false"

    # This is a CNAME, but the later `nslookup -type=txt <domain>` call will fail if set to the remote ns
    run get_auth_dns _acme-challenge.ubuntu-acmedns-getssl.freeddns.org
    assert_output --regexp 'set primary_ns=ns[0-9].dynu.com'
}

@test "Check get_auth_dns for a CNAME using public DNS and nslookup" {
    PUBLIC_DNS_SERVER=1.0.0.1
    AUTH_DNS_SERVER=
    CHECK_ALL_AUTH_DNS="false"
    CHECK_PUBLIC_DNS_SERVER="false"

    run get_auth_dns _acme-challenge.ubuntu-acmedns-getssl.freeddns.org
    assert_output --regexp 'set primary_ns=ns[0-9].dynu.com'
}
