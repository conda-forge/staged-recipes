#!/usr/bin/env bash
set -e

BUILD_DIR="build"

mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}

# Create build files
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_INSTALL_PREFIX=$LIBRARY_PREFIX% ${CMAKE_ARGS} ${SECP256K1_OPTIONS}

# Build
cmake --build . --target install ${CMAKE_BUILD_OPTIONS}

# Test
make check
