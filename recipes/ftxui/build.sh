#!/usr/bin/env bash
set -euxo pipefail

cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} -DCMAKE_INSTALL_LIBDIR=lib -DBUILD_SHARED_LIBS=ON

cmake --build build --parallel ${CPU_COUNT}
cmake --install build --prefix ${PREFIX}
