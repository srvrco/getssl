#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    for app in dig host nslookup
    do
        if [ -f /usr/bin/${app} ]; then
            mv /usr/bin/${app} /usr/bin/${app}.getssl.bak
        fi
    done

    . /getssl/getssl --source
    find_dns_utils
    _RUNNING_TEST=1
    _USE_DEBUG=0
}


teardown() {
    for app in dig host nslookup
    do
        if [ -f /usr/bin/${app}.getssl.bak ]; then
            mv /usr/bin/${app}.getssl.bak /usr/bin/${app}
        fi
    done
}


@test "Check get_auth_dns doesn't include root servers (drill NS)" {
    if [ ! -f /usr/bin/drill ]; then
        # Can't find drill package for centos8
        skip "Drill not installed on this system"
    fi

    # Test that get_auth_dns() handles scenario where NS query returns root servers
    # Issue #617
    #
    # Log output was:
    #   Verifying example.com
    #   checking DNS at h.root-servers.net for example.com. Attempt 1/100 gave wrong result, waiting 10 secs before checking again
    #   ... (retried until max attempts then failed)

    # Disable CNAME check, ensure SOA check is enabled
    _TEST_SKIP_CNAME_CALL=1
    _TEST_SKIP_SOA_CALL=1

    PUBLIC_DNS_SERVER=8.8.8.8
    CHECK_PUBLIC_DNS_SERVER=false
    CHECK_ALL_AUTH_DNS=true

    run get_auth_dns example.com

    # Assert that we've found the primary_ns server
    assert_output --regexp 'set primary_ns = '
    # Assert that we had to use drill NS
    assert_line --partial 'Using drill NS'

    # Check we didn't include any root servers
    refute_line --partial 'IN\WNS\W\.root-servers\.net\.'
}


@test "Check get_auth_dns doesn't include root servers (drill SOA)" {
    if [ ! -f /usr/bin/drill ]; then
        # Can't find drill package for centos8
        skip "Drill not installed on this system"
    fi

    # Test that get_auth_dns() handles scenario where NS query returns root servers
    # Issue #617
    #
    # Log output was:
    #   Verifying example.com
    #   checking DNS at h.root-servers.net for example.com. Attempt 1/100 gave wrong result, waiting 10 secs before checking again
    #   ... (retried until max attempts then failed)

    # Disable SOA and CNAME check
    _TEST_SKIP_CNAME_CALL=1
    _TEST_SKIP_SOA_CALL=0

    PUBLIC_DNS_SERVER=8.8.8.8
    CHECK_PUBLIC_DNS_SERVER=false
    CHECK_ALL_AUTH_DNS=true

    run get_auth_dns example.com

    # Assert that we've found the primary_ns server
    assert_output --regexp 'set primary_ns = '
    # Assert that we had to use drill SOA
    assert_line --partial 'Using drill SOA'

    # Check we didn't include any root servers
    refute_line --partial 'IN\WNS\W\.root-servers\.net\.'
}
