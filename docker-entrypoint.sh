#!/usr/bin/env bash
set -e

WORKING_DIR="/.getsslD"
cd $WORKING_DIR

if [ "$1" == "" ] && [ ! -f $WORKING_DIR/getsslD.cfg ]; then
    echo "Run with <-c DOMAIN> to initialize configuration files."
fi

/getsslD -w $WORKING_DIR -d "$@"

