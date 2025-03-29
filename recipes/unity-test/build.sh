#!/bin/sh

set -e
mkdir -p $PREFIX/include
mkdir build
cd build

cmake "${SRC_DIR}" -G "Ninja" \
    -DCMAKE_INSTALL_PREFIX:PATH="$PREFIX" \
    -DCMAKE_PREFIX_PATH:PATH="$PREFIX" \
    -DCMAKE_BUILD_TYPE:STRING=Release

cmake --build . --target install --config Release --parallel ${CPU_COUNT}