#!/usr/bin/env bash
set -e

WORKING_DIR="/getssl"
cd $WORKING_DIR

if [ "$1" == "" ] && [ ! -f $WORKING_DIR/getssl.cfg ]; then
    echo "Type <getssl -c DOMAIN> to initialize configuration files."
fi

getssl --nocheck -w $WORKING_DIR "$@"

