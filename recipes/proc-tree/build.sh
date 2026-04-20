#!/bin/bash

mkdir -p build && cd $_

cmake .. \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$PREFIX"

ninja -j$(nproc)
ninja install
