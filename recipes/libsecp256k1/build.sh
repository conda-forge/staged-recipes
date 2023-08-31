#!/usr/bin/env bash
set -e

BUILD_DIR="build"

mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}

# Create build files
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=Release ${CMAKE_ARGS} ${CMAKE_OPTIONS}

# Build
cmake --build . --config Release --target install ${CMAKE_BUILD_OPTIONS}

# Install
# cmake --install . --config Release --prefix $PREFIX
