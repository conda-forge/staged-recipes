#!/bin/bash
set -euo pipefail

cmake -G Ninja ${CMAKE_ARGS} \
    -DLIBDIVIDE_BUILD_TESTS=OFF \
    -DLIBDIVIDE_BUILD_FUZZERS=OFF \
    -DLIBDIVIDE_SSE2=OFF \
    -DLIBDIVIDE_AVX2=OFF \
    -DLIBDIVIDE_AVX512=OFF \
    -DLIBDIVIDE_NEON=OFF \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -B build -S .
cmake --install build
