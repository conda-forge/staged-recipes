#!/bin/bash
set -exo pipefail

cmake -S . -B build \
    ${CMAKE_ARGS} \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_TESTING=ON \
    -DBUILD_BENCHMARKS=OFF \
    -DISPC_EXECUTABLE="${BUILD_PREFIX}/bin/ispc" \
    -DOpenVDB_ROOT="${PREFIX}"
cmake --build build --parallel ${CPU_COUNT}
ctest -V --test-dir build --parallel ${CPU_COUNT}
cmake --install build
