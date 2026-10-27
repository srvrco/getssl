#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# Unit tests for date_renew() and date_renew_allow(): unless RENEW_ALLOW is set,
# renewal is allowed once a third of the certificate lifetime remains, so a
# 90 day certificate renews 30 days before expiry, a 45 day certificate 15 days
# before expiry and a 6 day (short lived) certificate 2 days before expiry.

setup() {
    [ ! -f "$BATS_RUN_TMPDIR/failed.skip" ] || skip "skipping tests after first failure"

    . /getssl/getssl --source

    # Sourcing with --source skips the main flow, so detect the OS here.
    # Without this, date_epoc uses GNU date syntax on busybox based images.
    get_os

    DAY=86400
    CERT_START=1700000000
    RENEW_ALLOW=""
}


teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch "$BATS_RUN_TMPDIR/failed.skip"
}


@test "date_renew renews a 90 day certificate 30 days before expiry" {
    cert_end=$(( CERT_START + 90 * DAY ))

    [ "$(date_renew "$CERT_START" "$cert_end")" -eq "$(( cert_end - 30 * DAY ))" ]
    [ "$(date_renew_allow "$CERT_START" "$cert_end")" = "30 days" ]
}


@test "date_renew renews a 45 day certificate 15 days before expiry" {
    cert_end=$(( CERT_START + 45 * DAY ))

    [ "$(date_renew "$CERT_START" "$cert_end")" -eq "$(( cert_end - 15 * DAY ))" ]
    [ "$(date_renew_allow "$CERT_START" "$cert_end")" = "15 days" ]
}


@test "date_renew renews a 6 day certificate 2 days before expiry" {
    cert_end=$(( CERT_START + 6 * DAY ))

    [ "$(date_renew "$CERT_START" "$cert_end")" -eq "$(( cert_end - 2 * DAY ))" ]
    [ "$(date_renew_allow "$CERT_START" "$cert_end")" = "2 days" ]
}


@test "date_renew uses a third of the lifetime when it isn't a whole number of days" {
    # Pebble issues certificates one second short of the profile lifetime
    cert_end=$(( CERT_START + 90 * DAY - 1 ))

    [ "$(date_renew "$CERT_START" "$cert_end")" -eq "$(( cert_end - (90 * DAY - 1) / 3 ))" ]
    [ "$(date_renew_allow "$CERT_START" "$cert_end")" = "30 days" ]

    cert_end=$(( CERT_START + 6 * DAY - 1 ))

    [ "$(date_renew "$CERT_START" "$cert_end")" -eq "$(( cert_end - (6 * DAY - 1) / 3 ))" ]
    [ "$(date_renew_allow "$CERT_START" "$cert_end")" = "2 days" ]
}


@test "date_renew_allow reports thresholds shorter than a day in hours" {
    cert_end=$(( CERT_START + 2 * DAY ))

    [ "$(date_renew_allow "$CERT_START" "$cert_end")" = "16 hours" ]
}


@test "date_renew uses RENEW_ALLOW days when it has been set" {
    cert_end=$(( CERT_START + 90 * DAY ))
    RENEW_ALLOW=20

    [ "$(date_renew "$CERT_START" "$cert_end")" -eq "$(( cert_end - 20 * DAY ))" ]
    [ "$(date_renew_allow "$CERT_START" "$cert_end")" = "20 days" ]
}


@test "date_renew ignores RENEW_ALLOW longer than the certificate lifetime" {
    # the old default of 30 days with a 6 day short lived certificate
    cert_end=$(( CERT_START + 6 * DAY ))
    RENEW_ALLOW=30

    [ "$(date_renew "$CERT_START" "$cert_end")" -eq "$(( cert_end - 2 * DAY ))" ]
    [ "$(date_renew_allow "$CERT_START" "$cert_end")" = "2 days" ]

    # 2000 days with a 90 day certificate
    cert_end=$(( CERT_START + 90 * DAY ))
    RENEW_ALLOW=2000

    [ "$(date_renew "$CERT_START" "$cert_end")" -eq "$(( cert_end - 30 * DAY ))" ]
}


@test "date_renew honours RENEW_ALLOW equal to the certificate lifetime" {
    # Pebble issues certificates one second short of the profile lifetime, so
    # RENEW_ALLOW is compared against the lifetime rounded up to whole days
    cert_end=$(( CERT_START + 6 * DAY - 1 ))
    RENEW_ALLOW=6

    [ "$(date_renew "$CERT_START" "$cert_end")" -eq "$(( cert_end - 6 * DAY ))" ]

    cert_end=$(( CERT_START + 90 * DAY - 1 ))
    RENEW_ALLOW=90

    [ "$(date_renew "$CERT_START" "$cert_end")" -eq "$(( cert_end - 90 * DAY ))" ]
}


@test "renew_allow_exceeds_lifetime reports whether RENEW_ALLOW is ignored" {
    cert_end=$(( CERT_START + 90 * DAY ))

    RENEW_ALLOW=""
    refute renew_allow_exceeds_lifetime "$CERT_START" "$cert_end"

    RENEW_ALLOW=30
    refute renew_allow_exceeds_lifetime "$CERT_START" "$cert_end"
    assert renew_allow_exceeds_lifetime "$CERT_START" "$(( CERT_START + 6 * DAY ))"

    # equal to the lifetime (rounded up) is not longer than the lifetime
    RENEW_ALLOW=6
    refute renew_allow_exceeds_lifetime "$CERT_START" "$(( CERT_START + 6 * DAY - 1 ))"

    # unknown lifetime - the value can't be compared, so it is honoured
    refute renew_allow_exceeds_lifetime "-" "$cert_end"
}


@test "date_renew allows renewal at expiry when RENEW_ALLOW is zero" {
    cert_end=$(( CERT_START + 90 * DAY ))
    RENEW_ALLOW=0

    [ "$(date_renew "$CERT_START" "$cert_end")" -eq "$cert_end" ]
}


@test "date_renew falls back to 30 days when the lifetime is unknown" {
    cert_end=$(( CERT_START + 90 * DAY ))

    # no start date
    [ "$(date_renew "-" "$cert_end")" -eq "$(( cert_end - 30 * DAY ))" ]

    # start date after the end date
    [ "$(date_renew "$cert_end" "$CERT_START")" -eq "$(( CERT_START - 30 * DAY ))" ]

    # an explicit RENEW_ALLOW is used as it can't be compared to the lifetime
    RENEW_ALLOW=15
    [ "$(date_renew "-" "$cert_end")" -eq "$(( cert_end - 15 * DAY ))" ]
}


@test "date_renew allows renewal when there is no usable expiry date" {
    [ "$(date_renew "$CERT_START" "")" -eq 0 ]
    [ "$(date_renew "$CERT_START" "-")" -eq 0 ]
}


@test "date_renew returns the point where a third of the lifetime remains" {
    cert_end=$(( CERT_START + 45 * DAY ))
    renew_at=$(date_renew "$CERT_START" "$cert_end")

    # two thirds through the lifetime
    [ "$renew_at" -eq $(( CERT_START + (2 * (45 * DAY)) / 3 )) ]
    # with a third of the lifetime remaining
    [ $(( cert_end - renew_at )) -eq $(( (cert_end - CERT_START) / 3 )) ]
}
