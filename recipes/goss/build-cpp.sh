#!/bin/bash
cd cpp

export CMAKE_BUILD_PARALLEL_LEVEL=${CPU_COUNT}

# explicitly link cblas, since FindBLAS doesn't cover it,
# but it's needed when building against netlib
cmake \
  ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -B build-dir \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_CXX_COMPILER=$(basename $CXX) \
  -DBLA_VENDOR="Generic" \
  -S .
cmake --build build-dir
cmake --install build-dir