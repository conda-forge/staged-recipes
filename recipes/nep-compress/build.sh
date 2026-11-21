#!/bin/bash
set -euxo pipefail

plugins="${PREFIX}/lib/hdf5/plugin"

cmake -S . -B build -G Ninja ${CMAKE_ARGS} \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DHDF5_ROOT="${PREFIX}" \
  -DBUILD_TESTING=ON \
  -DNEPCOMPRESS_BUILD_LZ4=ON \
  -DNEPCOMPRESS_BUILD_BZIP2=ON \
  -DNEPCOMPRESS_ENABLE_FORTRAN=ON \
  -DNEPCOMPRESS_BZIP2_PLUGIN_DIR="${plugins}" \
  -DNEPCOMPRESS_ZSTD_PLUGIN_DIR="${plugins}"
cmake --build build --parallel "${CPU_COUNT}"
ctest --test-dir build --output-on-failure --no-tests=error --parallel "${CPU_COUNT}"
cmake --install build

mkdir -p "${plugins}"
mv "${PREFIX}/lib/plugin/libh5lz4.so" "${plugins}/libh5lz4_nepcompress.so"
rmdir "${PREFIX}/lib/plugin"
