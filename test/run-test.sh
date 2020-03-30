#! /usr/bin/env bash

if [ $# -eq 0 ]; then
    echo "Usage: $(basename "$0") <os> [<command>]"
    echo "e.g. $(basename "$0") alpine bats /getssl/test"
    exit 1
fi
OS=$1

if [ $# -gt 1 ]; then
    shift
    COMMAND=$*
else
    COMMAND="bats /getssl/test"
fi

if [[ "$OS" == *"staging"* ]]; then
    ALIAS="${OS%-staging}-getssl.duckdns.org"
    STAGING="--env STAGING=true"
else
    ALIAS="$OS.getssl.test"
    STAGING=""
fi

docker build --rm -f "test/Dockerfile-$OS" -t "getssl-$OS" .
# shellcheck disable=SC2086
docker run \
  --env GETSSL_HOST=$ALIAS $STAGING \
  --env GETSSL_OS=${OS%-staging} \
  -v "$(pwd)":/getssl \
  --rm \
  --network ${PWD##*/}_acmenet \
  --network-alias $ALIAS \
  --network-alias "a.$OS.getssl.test" \
  --network-alias "b.$OS.getssl.test" \
  --network-alias "c.$OS.getssl.test" \
  --network-alias "d.$OS.getssl.test" \
  --network-alias "e.$OS.getssl.test" \
  --network-alias "f.$OS.getssl.test" \
  --network-alias "g.$OS.getssl.test" \
  --network-alias "h.$OS.getssl.test" \
  --network-alias "i.$OS.getssl.test" \
  --network-alias "j.$OS.getssl.test" \
  --network-alias "k.$OS.getssl.test" \
  --name "getssl-$OS" \
  "getssl-$OS" \
  $COMMAND
