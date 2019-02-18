#!/bin/bash

set -x
echo ${PREFIX}
export CXXFLAGS="${CXXFLAGS} -fopenmp"
./configure --prefix="${PREFIX}" --enable-shared

make -j${CPU_COUNT}
make -j${CPU_COUNT} check
make -j${CPU_COUNT} install
