#!/usr/bin/env bash

# Abort on error.
set -ex

# Build out-of-tree.
mkdir build
cd build

# Config
cmake -G Ninja \
    ${CMAKE_ARGS} \
    -DANTS_SUPERBUILD:BOOL=OFF \
    -DBUILD_SHARED_LIBS:BOOL=ON \
    -DCMAKE_BUILD_TYPE:STRING=Release \
    -DCMAKE_INSTALL_LIBDIR:STRING=lib \
    -DCMAKE_INSTALL_PREFIX:STRING=${PREFIX} \
    -DCMAKE_PREFIX_PATH:STRING=${PREFIX} \
    -DRUN_SHORT_TESTS:BOOL=ON \
    -DRUN_LONG_TESTS:BOOL=OFF \
    -DUSE_SYSTEM_ITK:BOOL=ON \
    ${SRC_DIR}

# Build
cmake --build . --config Release --parallel ${CPU_COUNT}

# Test
ctest -C Release --output-on-failure

# Install
cmake --build . --config Release --target install
