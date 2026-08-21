#!/bin/bash
set -euxo pipefail

# remove any stale build dir copied in with the source (avoids CMakeCache path mismatch)
rm -rf build

mkdir -p build
cd build

cmake ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  ..

make -j"${CPU_COUNT:-2}"
make install
