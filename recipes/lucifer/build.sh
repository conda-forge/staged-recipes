#!/bin/bash
set -euxo pipefail

export HDF5_ROOT="$PREFIX"

cmake -S . -B build ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DLUCIFER_BMAD_ROOT="$PREFIX" \
  -DLUCIFER_VERSION="v${PKG_VERSION}"
cmake --build build --parallel "${CPU_COUNT}"

cmake --install build

install -d "$PREFIX/lib" "$PREFIX/include/lucifer"
install -m 644 build/lib/liblucifer.a "$PREFIX/lib/"
install -m 644 build/modules/*.mod "$PREFIX/include/lucifer/"
