#!/usr/bin/env bash
set -ex

mkdir build
cd build
cmake \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DBUILD_TESTING=OFF \
    ..
make -j${CPU_COUNT}
make install
