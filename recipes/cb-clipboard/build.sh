#!/bin/bash

set -exuo pipefail

mkdir -p build
cd build

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_CXX_FLAGS="-march=native" ..
make -j${CPU_COUNT}
make install
