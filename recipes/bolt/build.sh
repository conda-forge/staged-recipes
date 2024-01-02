#!/bin/bash
set -ex

mkdir build
cd build

cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    ${CMAKE_ARGS} \
    ../bolt

cmake --build .
cmake --install .
