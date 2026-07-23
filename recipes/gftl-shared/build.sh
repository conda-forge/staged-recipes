#!/usr/bin/env bash
set -euxo pipefail

# find_package(GFTL) resolves $PREFIX/GFTL-1.17/cmake via CMAKE_PREFIX_PATH (conda
# sets it to $PREFIX). BUILD_TESTING=OFF -- upstream's tests want pFUnit, which is
# above this package in the dependency chain.
#
# CMAKE_ARGS is a flag STRING from the compiler activation and must word-split.
# shellcheck disable=SC2086
cmake -G Ninja -S . -B build \
  ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DBUILD_TESTING=OFF

cmake --build build --parallel "${CPU_COUNT:-2}"
cmake --install build
