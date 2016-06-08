#!/usr/bin/env bash

if [[ `uname` == 'Darwin' ]]; then
    export CFLAGS="${CFLAGS} -pthread"
    export LDFLAGS="${LDFLAGS} -lpthread"
fi

$PYTHON -B setup.py install --single-version-externally-managed --record record.txt
