#!/usr/bin/env bash
set -e


mkdir build
cd build

cmake $SRC_DIR -G"Ninja" \
    -D CMAKE_BUILD_TYPE="Release" \
    -D CMAKE_INSTALL_PREFIX:PATH="${PREFIX}" \
    -D CMAKE_INSTALL_LIBDIR="lib" \
    -D HPX_WITH_EXAMPLES=OFF \
    -D HPX_WITH_MALLOC="tcmalloc" \
    -D HPX_WITH_NETWORKING=OFF \
    -D HPX_WITH_TESTS=OFF
cmake --build . --parallel ${CPU_COUNT}
cmake --install .
