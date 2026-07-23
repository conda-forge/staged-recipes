#!/usr/bin/env bash
set -euxo pipefail

# Upstream ships both autotools and CMake; CMake is the maintained path and the
# one Spack uses. BUILD_TESTING also gates examples/benchmarks, which we skip.
#
# CMAKE_ARGS is a flag STRING from the compiler activation and must word-split.
# shellcheck disable=SC2086
cmake -G Ninja -S . -B build \
  ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DBUILD_SHARED_LIBS=ON \
  -DBUILD_TESTING=OFF \
  -DBUILD_DOC=OFF

cmake --build build --parallel "${CPU_COUNT:-2}"
cmake --install build
