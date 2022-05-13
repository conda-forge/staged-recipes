#!/bin/bash
cd cpp

# explicitly link cblas, since FindBLAS doesn't cover it,
# but it's needed when building against netlib
cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -B build-dir \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DBLA_VENDOR="Generic" \
  -DBLAS_LIBRARIES="$PREFIX/lib/libblas${SHLIB_EXT};$PREFIX/lib/libcblas${SHLIB_EXT}" \
  -S .
cmake --build build-dir
cmake --install build-dir
