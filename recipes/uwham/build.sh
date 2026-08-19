#!/bin/bash
set -euxo pipefail

# remove any stale build dir copied in with the source (avoids CMakeCache path mismatch)
rm -rf build

mkdir -p build
cd build

cmake .. \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_CXX_COMPILER="$CXX"

make -j"${CPU_COUNT:-2}"
make install
