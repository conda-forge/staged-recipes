#!/bin/bash -x

# make sure that compiler has been sourced, if necessary

if [ `uname` == Darwin ]; then
    export MACOSX_DEPLOYMENT_TARGET=10.10
fi

CFLAGS="-I$PREFIX/include $CFLAGS" $PYTHON setup.py build --force install --old-and-unmanageable

