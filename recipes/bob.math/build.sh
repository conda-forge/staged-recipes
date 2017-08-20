#!/usr/bin/env bash

if [[ `uname` == 'Darwin' ]]; then
    export MACOSX_DEPLOYMENT_TARGET=10.9
fi

export CFLAGS="${CFLAGS} -pthread"
export LDFLAGS="${LDFLAGS} -lpthread"

# Use only 1 thread with OpenBLAS to avoid timeouts on CIs.
# This should have no other affect on the build. A user
# should still be able to set this (or not) to a different
# value at run-time to get the expected amount of parallelism.
export OPENBLAS_NUM_THREADS=1

$PYTHON -B setup.py install --single-version-externally-managed --record record.txt
