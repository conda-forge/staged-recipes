#!/bin/bash
set -ex

export CFLAGS="${CFLAGS} -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -I${PREFIX}/lib"

python setup.py install --single-version-externally-managed --record=record.txt
