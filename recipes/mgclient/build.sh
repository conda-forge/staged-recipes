#!/bin/bash
set -euxo pipefail

cmake ${CMAKE_ARGS} -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DBUILD_TESTING=OFF
cmake --build build --parallel "${CPU_COUNT}"
cmake --install build

# conda-forge does not allow static libraries
rm -f "${PREFIX}/lib/libmgclient.a"
