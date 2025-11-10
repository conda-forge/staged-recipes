#!/bin/bash

set -euo pipefail

mkdir -p build
cd build
cmake -GNinja $CMAKE_ARGS \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCPR_USE_SYSTEM_CURL=ON \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_INSTALL_LIBDIR=lib \
  ../
ninja
ninja install
