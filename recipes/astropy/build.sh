#!/bin/bash

if [[ `uname` == Linux ]]; then
    export CFLAGS="$CFLAGS -std=c99"
    export CC=gcc
fi

$PYTHON setup.py install --offline --old-and-unmanageable
