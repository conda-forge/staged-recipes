#!/bin/bash
set -euxo pipefail

# The VERSION file in the v2.1.0 release archive still carries the "-dev" suffix
echo "${PKG_VERSION}" > VERSION

# Build the compiled part for the baseline instruction set; the headers use the consumer's flags
case "${target_platform}" in
  linux-64|osx-64) simd=SSE2 ;;
  *) simd=NONE ;;
esac

cmake -S . -B build -G Ninja ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DXAD_ENABLE_TESTS=OFF \
  -DXAD_WARNINGS_PARANOID=OFF \
  -DXAD_SIMD_OPTION=${simd}
cmake --build build --parallel ${CPU_COUNT}
cmake --install build

rm -rf "${PREFIX}/share/doc/xad"
