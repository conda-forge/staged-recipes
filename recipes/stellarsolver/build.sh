#!/usr/bin/env bash
set -euxo pipefail

# Expose the vasprintf declaration used by the bundled Astrometry.net C code.
if [[ "${target_platform}" == linux-* ]]; then
    export CFLAGS="${CFLAGS} -D_GNU_SOURCE"
fi

cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DUSE_QT5=ON \
    -DBUILD_CLI=ON \
    -DBUILD_TESTER=OFF \
    -DBUILD_BATCH_SOLVER=OFF \
    -DBUILD_DEMOS=OFF \
    -DBUILD_TESTS=OFF

cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
