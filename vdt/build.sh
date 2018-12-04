#!/bin/bash
set -ex

mkdir build-dir
cd build-dir

cmake \
    -DCMAKE_BUILD_TYPE=release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_LIBDIR="${PREFIX}/lib" \
    -DCMAKE_CXX_COMPILER="${GXX}" \
    -DCMAKE_CC_COMPILER="${GCC}" \
    ..

make -j${CPU_COUNT}

make install
