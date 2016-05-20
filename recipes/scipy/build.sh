#!/bin/bash

if [ `uname` == Darwin ]
then
    FCFLAGS=$CFLAGS
    LDFLAGS="-undefined dynamic_lookup -bundle -Wl,-search_paths_first -L$(pwd) $LDFLAGS"
fi

$PYTHON setup.py install
