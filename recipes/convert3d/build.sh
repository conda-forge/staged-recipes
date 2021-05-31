#!/usr/bin/env bash

mkdir build
cd build

cmake $CMAKE_ARGS -GNinja \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_PREFIX:STRING=$PREFIX \
    ..

cmake --build .

ctest --extra-verbose --output-on-failure .

cmake --install .
