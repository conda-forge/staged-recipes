#!/usr/bin/env bash
set -euo pipefail

# Build with the project's non-UPS path: SKIP_CET=ON avoids cetmodules and uses
# the plain-CMake install rules in duneanaobj/StandardRecord/CMakeLists.txt.
cmake ${CMAKE_ARGS} -GNinja \
    -DCMAKE_BUILD_TYPE=Release \
    -DSKIP_CET=ON \
    -DBUILD_SHARED_LIBS=ON \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -S "${SRC_DIR}" \
    -B build

cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
