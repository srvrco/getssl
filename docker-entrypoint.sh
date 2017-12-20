#!/usr/bin/env bash
set -e

WORKING_DIR="/getsslD"
cd $WORKING_DIR

if [ "$1" == "" ] && [ ! -f $WORKING_DIR/getsslD.cfg ]; then
    echo "Type <getsslD -c DOMAIN> to initialize configuration files."
fi

getsslD --nocheck -w $WORKING_DIR "$@"

