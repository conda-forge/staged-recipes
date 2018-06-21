#!/usr/bin/env bash
export CFLAGS="-I$PREFIX/include -I${BUILD_PREFIX}/include"
export CPPFLAGS="-I$PREFIX/include -I${BUILD_PREFIX}/include"
export CXXFLAGS="${CFLAGS}"
export LDFLAGS="-L${PREFIX}/lib -L${BUILD_PREFIX}/lib"

# Python command to install the script.
python setup.py install --single-version-externally-managed --record=record.txt  --prefix="${PREFIX}"
