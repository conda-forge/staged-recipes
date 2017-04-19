#!/usr/bin/env bash

if [[ `uname` == 'Darwin' ]]; then
    export MACOSX_DEPLOYMENT_TARGET=10.9
    export CFLAGS="${CFLAGS} -pthread"
    export LDFLAGS="${LDFLAGS} -lpthread"
fi

$PYTHON setup.py install
