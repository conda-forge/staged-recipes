#!/usr/bin/env bash
set -euxo pipefail

cmake ${CMAKE_ARGS} -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DBUILD_SHARED_LIBS=ON \
  -DRGPOT_PURE_LIB=ON \
  -DRGPOT_WITH_RPC=OFF \
  -DRGPOT_WITH_CACHE=OFF \
  -DRGPOT_WITH_FORTRAN=OFF \
  -DRGPOT_BUILD_EXAMPLES=OFF \
  -DRGPOT_BUILD_TESTS=OFF \
  -DRGPOT_WITH_EIGEN=OFF \
  -DRGPOT_WITH_XTENSOR=OFF \
  -B build -S .

cmake --build build --parallel "${CPU_COUNT:-2}"
cmake --install build
