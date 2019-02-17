#!/bin/bash

set -x
echo ${PREFIX}
if [ "$(uname)" == "Darwin" ]; then
    export CXXFLAGS="${CXXFLAGS} -fPIC"
else
    export CXXFLAGS="${CXXFLAGS} -fPIC -fopenmp"
fi
./configure --prefix="${PREFIX}" --enable-shared

make -j${CPU_COUNT}
make -j${CPU_COUNT} check
make -j${CPU_COUNT} install
