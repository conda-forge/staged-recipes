#!/bin/bash
set -euxo pipefail

export HDF5_ROOT="$PREFIX"

cmake -S . -B build ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON \
  -DLUCIFER_BMAD_ROOT="$PREFIX" \
  -DLUCIFER_VERSION="v${PKG_VERSION}"
cmake --build build --parallel "${CPU_COUNT}"

# Places bin/lucifer, lib/liblucifer, include/lucifer/*.mod and lib/cmake/lucifer.
cmake --install build
