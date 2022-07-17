#!/bin/bash
set -ex

mkdir build
cd build

cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    ..

cmake --build .
cmake --install --prefix $PREFIX
