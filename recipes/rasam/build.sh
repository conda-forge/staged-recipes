#!/usr/bin/env bash
set -e

BUILD_DIR="build"

mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}

# Create build files
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=Release

# Build and install
cmake --build . --config Release --target install