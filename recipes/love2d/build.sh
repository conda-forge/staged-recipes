#!/bin/sh

set -euxo pipefail

mkdir build
cd build

# Configure using the CMakeFiles
cmake -G Ninja \
    ${CMAKE_ARGS} \
    -D CMAKE_INSTALL_PREFIX=$PREFIX \
    -D LOVE_JIT=OFF \
    $SRC_DIR

# Build
cmake --build .

# Install
cmake --build . --target install