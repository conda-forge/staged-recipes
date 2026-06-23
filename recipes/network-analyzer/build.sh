#!/bin/bash

rm -rf build
mkdir -p build && cd $_

cmake .. \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    -DCMAKE_PREFIX_PATH="$PREFIX" \
    ${CMAKE_ARGS}

ninja
ninja install