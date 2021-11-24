#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    [ ! -f $BATS_RUN_TMPDIR/failed.skip ] || skip "skipping tests after first failure"
    cp /etc/resolv.conf /etc/resolv.conf.getssl
    cat <<- EOF > /etc/resolv.conf
nameserver 8.8.8.8
options ndots:0
EOF

    for app in drill host nslookup
    do
        if [ -f /usr/bin/${app} ]; then
            mv /usr/bin/${app} /usr/bin/${app}.getssl.bak
        fi
    done

    . /getssl/getssl --source
    find_dns_utils
    _USE_DEBUG=1
}


teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch $BATS_RUN_TMPDIR/failed.skip
    cat /etc/resolv.conf.getssl > /etc/resolv.conf
    for app in drill host nslookup
    do
        if [ -f /usr/bin/${app}.getssl.bak ]; then
            mv /usr/bin/${app}.getssl.bak /usr/bin/${app}
        fi
    done
}


@test "Check get_auth_dns doesn't include root servers (dig NS)" {
    # Test that get_auth_dns() handles scenario where NS query returns root servers
    # Issue #617
    #
    # Log output was:
    #   Verifying example.com
    #   checking DNS at h.root-servers.net for example.com. Attempt 1/100 gave wrong result, waiting 10 secs before checking again
    #   ... (retried until max attempts then failed)

    # Disable SOA and CNAME check
    _TEST_SKIP_CNAME_CALL=1
    _TEST_SKIP_SOA_CALL=1

    PUBLIC_DNS_SERVER=
    CHECK_PUBLIC_DNS_SERVER=false
    CHECK_ALL_AUTH_DNS=true

    run get_auth_dns example.com

    # Assert that we've found the primary_ns server
    assert_output --regexp 'set primary_ns = '
    # Assert that we had to use dig NS
    assert_line --regexp 'Using dig.* NS'

    # Check we didn't include any root servers
    refute_line --partial 'root-servers.net'
}


@test "Check get_auth_dns doesn't include root servers (dig SOA)" {
    # Test that get_auth_dns() handles scenario where NS query returns root servers
    # Issue #617
    #
    # Log output was:
    #   Verifying example.com
    #   checking DNS at h.root-servers.net for example.com. Attempt 1/100 gave wrong result, waiting 10 secs before checking again
    #   ... (retried until max attempts then failed)

    # Disable CNAME check, ensure SOA check is enabled
    _TEST_SKIP_CNAME_CALL=1
    _TEST_SKIP_SOA_CALL=0

    PUBLIC_DNS_SERVER=
    CHECK_PUBLIC_DNS_SERVER=false
    CHECK_ALL_AUTH_DNS=true

    run get_auth_dns example.com

    # Assert that we've found the primary_ns server
    assert_output --regexp 'set primary_ns = '
    # Assert that we had to use dig SOA
    assert_line --regexp 'Using dig.* SOA'

    # Check we didn't include any root servers
    refute_line --partial 'root-servers.net'
}
