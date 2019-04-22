#!/bin/bash -x

# make sure that compiler has been sourced, if necessary

CFLAGS="-I${PREFIX}/include ${CFLAGS}" $PYTHON setup.py build --force install --old-and-unmanageable
