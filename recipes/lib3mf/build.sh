#!/bin/bash

set -x

mkdir build
cd build
cmake \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_LIBDIR="${PREFIX}/lib" \
    -DCMAKE_BUILD_TYPE:String=Release \
    -DLIB3MF_TESTS=OFF \
    -GNinja \
    ..

ninja
ninja install