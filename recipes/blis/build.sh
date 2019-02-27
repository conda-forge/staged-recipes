#!/usr/bin/env bash

export BLIS_COMPILER="$CC"
export CFLAGS="-lrt"
export LDFLAGS="-lrt"
$PYTHON -m pip install . --no-deps -vv
