#!/bin/bash

set -ex  # Abort on error.

mkdir build
cd build

cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DENABLE_PYTHON=ON \
    "${SRC_DIR}"

make -j"${CPU_COUNT}"
make install

ctest -VV --output-on-failure 