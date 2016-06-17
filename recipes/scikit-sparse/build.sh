#!/bin/bash

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib -Wl,-rpath,${PREFIX}/lib"
export CFLAGS="${CFLAGS} -I${PREFIX}/include"

$PYTHON setup.py install --single-version-externally-managed --record record.txt
