#!/usr/bin/env bash

export BLIS_COMPILER="$CC"
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    export CFLAGS="-lrt"
    export LDFLAGS="-lrt"
fi
$PYTHON -m pip install . --no-deps -vv
