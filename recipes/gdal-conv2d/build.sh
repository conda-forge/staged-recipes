#!/usr/bin/env bash
set -euo pipefail

# Build + install the C++ binary as $PREFIX/bin/gdal-conv2d
mkdir -p cpp/build
cd cpp/build
cmake .. \
    -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$PREFIX" \
    -DCMAKE_PREFIX_PATH="$PREFIX"
cmake --build . -j "${CPU_COUNT}"
cmake --install .
