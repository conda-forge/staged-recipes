#!/bin/bash

set -ex

mkdir build
cd build

cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DASMJIT_STATIC=OFF \
    -DASMJIT_TEST=ON \
    -DASMJIT_NO_CUSTOM_FLAGS=OFF \
    ..

cmake --build . --config Release --parallel ${CPU_COUNT}

# Run tests to verify the build
# This must be done here, because otherwise we need to re-build the lib in test phase, which
ctest --output-on-failure --verbose

cmake --install . --config Release
