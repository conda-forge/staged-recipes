#!/bin/bash

set -exuo pipefail

export CFLAGS="${CFLAGS/-Os/-O3}"
export CXXFLAGS="${CXXFLAGS/-Os/-O3}"

mkdir -p build
cd build

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make -j${CPU_COUNT}
make install
