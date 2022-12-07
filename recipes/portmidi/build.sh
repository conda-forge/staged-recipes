#!/bin/bash
set -ex

mkdir build
cd build

cmake ${CMAKE_ARGS} -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DBUILD_SHARED_LIBS=ON \
    ..

cmake --build .
cmake --install . --prefix $PREFIX
