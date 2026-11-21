#!/usr/bin/env bash
set -euxo pipefail

mkdir -p build && cd build

cmake ${CMAKE_ARGS} \
    -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_FAKENECT=ON \
    -DBUILD_C_SYNC=ON \
    -DBUILD_CPP=ON \
    -DBUILD_CV=OFF \
    -DBUILD_PYTHON=OFF \
    -DBUILD_PYTHON2=OFF \
    -DBUILD_PYTHON3=OFF \
    -DBUILD_REDIST_PACKAGE=ON \
    ..

ninja -j${CPU_COUNT}
ninja install