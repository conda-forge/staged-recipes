#!/bin/sh

if [ $(uname) == Darwin ]; then
    export CFLAGS="-arch x86_64"
    export FFLAGS="-static -ff2c -arch x86_64"
    export LDFLAGS="-Wall -undefined dynamic_lookup -bundle -arch x86_64"
    export LDFLAGS="-Wl,-search_paths_first -L$(pwd) $LDFLAGS"
fi

$PYTHON setup.py install
