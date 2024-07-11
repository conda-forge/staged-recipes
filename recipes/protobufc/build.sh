#!/bin/bash

set -ex

cd build-cmake
mkdir build
cd build


cmake ${CMAKE_ARGS} -G Ninja \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    ..

ninja -j${CPU_COUNT}
ninja install
