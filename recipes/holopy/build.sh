#!/bin/bash

if [ $(uname) == Darwin ]; then
    export CFLAGS="${CFLAGS} -arch x86_64"
    export FFLAGS="${FFLAGS} -static -ff2c -arch x86_64"
    export LDFLAGS="${LDFLAGS} -Wall -undefined dynamic_lookup -bundle -arch x86_64"
    export LDFLAGS="${LDFLAGS} -Wl,-search_paths_first -L$(pwd) $LDFLAGS"
fi


$PYTHON setup.py install --single-version-externally-managed --record record.txt
