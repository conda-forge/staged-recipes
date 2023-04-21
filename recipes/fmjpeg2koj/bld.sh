#!/usr/bin/env bash

mkdir build
cd build

cmake \
    -D CMAKE_BUILD_TYPE:STRING=Release \
    -D CMAKE_INSTALL_PREFIX="${PREFIX}" \
    ..

cmake --build . --target install --parallel