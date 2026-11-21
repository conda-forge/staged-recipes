#!/bin/bash
set -euxo pipefail

# shellcheck disable=SC2086  # CMAKE_ARGS holds several arguments
cmake -S . -B build -G Ninja ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TESTING=OFF \
    -DBUILD_SZ3_BINARY=ON \
    -DBUILD_H5Z_FILTER=ON \
    -DSZ3_USE_BUNDLED_ZSTD=OFF \
    -DH5Z_SZ3_PLUGIN_INSTALL_DIR=lib/hdf5/plugin

# SZ3 falls back to its bundled Zstd when find_library finds none; conda-forge's must be used.
grep -q "^SZ3_ZSTD_LIBRARY:FILEPATH=$PREFIX/lib/libzstd" build/CMakeCache.txt

cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
