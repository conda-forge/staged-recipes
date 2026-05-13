#!/usr/bin/env bash
set -euo pipefail

# Build + install the C++ binary as $PREFIX/bin/gdal-conv2d
cmake -G Ninja -DCMAKE_PREFIX_PATH=$PREFIX -S cpp -B build
cmake --build build --parallel ${CPU_COUNT}
cmake --install build
