#!/usr/bin/env bash
set -ex

# Always build from the conda-provided source directory
cd "$SRC_DIR"

# Create an out-of-source build
mkdir build
cd build

# Configure with CMake
cmake .. \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_BUILD_TYPE=Release

# Build and install
cmake --build . --config Release
cmake --install .
