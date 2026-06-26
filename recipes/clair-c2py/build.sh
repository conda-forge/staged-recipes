#!/usr/bin/env bash
set -euxo pipefail

# clair uses no C++20 modules; disable CMake's module dependency scanning so the
# build does not require clang-scan-deps (not shipped in this environment).
cmake -S . -B build -G Ninja ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DPython_EXECUTABLE="$PYTHON" \
  -DCMAKE_CXX_SCAN_FOR_MODULES=OFF \
  -DBuild_Tests=OFF \
  -DBuild_Documentation=OFF

cmake --build build -j"${CPU_COUNT}"
cmake --install build
