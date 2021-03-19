#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib"
export CFLAGS="${CFLAGS} -I${PREFIX}/include"

$PYTHON -m pip install . -vv