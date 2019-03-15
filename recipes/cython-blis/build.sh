#!/usr/bin/env bash

export BLIS_COMPILER="$CC"
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    export CFLAGS="$CFLAGS -lrt"
    export LDFLAGS="$LDFLAGS -lrt"
fi
$PYTHON -m pip install . --no-deps -vv
