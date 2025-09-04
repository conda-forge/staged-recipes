#!/bin/bash

set -ex

mkdir -p build
cd build

cmake ${CMAKE_ARGS} \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DBUILD_SHARED_LIBS=ON \
    -DLIBSRTP_TEST_APPS=OFF \
    -DENABLE_WARNINGS_AS_ERRORS=OFF \
    ..

ninja -j${CPU_COUNT}
ninja install
