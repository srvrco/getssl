#! /usr/bin/env bats

load '/bats-support/load.bash'
load '/bats-assert/load.bash'
load '/getssl/test/test_helper.bash'


# This is run for every test
setup() {
    [ ! -f $BATS_RUN_TMPDIR/failed.skip ] || skip "skipping tests after first failure"

    . /getssl/getssl --source
    export API=2
    _USE_DEBUG=1
}


teardown() {
    [ -n "$BATS_TEST_COMPLETED" ] || touch $BATS_RUN_TMPDIR/failed.skip
}

response='
{
    "challenges": [
        {
            "status": "pending",
            "token": "kD1H4FVIEFvkWghLlKFoSPpR5u0FTGkRs4A_FnTfv3A",
            "type": "http-01",
            "url": "https://pebble:14000/chalZ/firw72KAYbsChpxMAzrTSLpCKepAdqcJn7NERZtAknY"
        },
        {
            "status": "pending",
            "token": "3FMfZoNNrjZzh_nnxanW5oEKvC6urlGS5wQWI5Bg9J4",
            "type": "dns-01",
            "url": "https://pebble:14000/chalZ/vkHAS1A9tQQ5A8QoAIRQJrSC_WJNm303iwC1r22dnCc"
        },
        {
            "status": "pending",
            "token": "UGkg34cDGoM9Su22iCH9yn383uLfTpr5Ys4Tms9QYAo",
            "type": "dns-account-01",
            "url": "https://pebble:14000/chalZ/ryNLsf-iOe22YYeYv6YIwBp7E2z492bdesvNQFzl9gI"
        },
        {
            "status": "pending",
            "token": "Sla6q_0Nl3JB3JMsWCXn_X3-KyH45mjKaStRDZU8I0g",
            "type": "tls-alpn-01",
            "url": "https://pebble:14000/chalZ/pzLqpT2qVf4DxK25GX0mONLE9Ii35FAXL9ioxONoSFQ"
        }
    ],
    "expires": "2024-10-18T17:24:42Z",
    "identifier": {
        "type": "dns",
        "value": "c.debian.getssl.test"
    },
    "status": "pending"
}'


@test "Test that json_get fails if token contains the phrase 'url'" {
    # the token for te dns-01 entry contains the text "url" which breaks the json_get url parser!

    type="dns-01"
    uri=$(json_get "$response" "challenges" "type" $type "url")
    token=$(json_get "$response" "challenges" "type" $type "token")
    # when using pebble this sometimes appears to have a newline which causes problems in send_signed_request
    uri=$(echo "$uri" | tr -d '\r')
    echo uri "$uri" >&3
    echo token "$token" >&3

    # check the uri begins with https
    begins_with_https=0
    if [[ "$uri" == https* ]]; then
        begins_with_https=1
    fi

    assert_not_equal $begins_with_https 1
}


@test "Test that json_get works if we quote 'url'" {
    # the token for te dns-01 entry contains the text "url" which breaks the json_get url parser!

    type="dns-01"
    uri=$(json_get "$response" "challenges" "type" $type '"url"')
    token=$(json_get "$response" "challenges" "type" $type '"token"')
    echo uri "$uri" >&3
    echo token "$token" >&3

    # check the uri begins with https
    begins_with_https=0
    if [[ "$uri" == https* ]]; then
        begins_with_https=1
    fi

    assert_equal $begins_with_https 1
}
