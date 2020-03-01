#! /usr/bin/env bash

if [ "$GETSSL_HOST" = "alpine.getssl.test" ]; then
    # start nginx in background
    /usr/bin/supervisord -c /etc/supervisord.conf &
    sleep 5  # to allow for initialization
fi

bats /getssl/test
