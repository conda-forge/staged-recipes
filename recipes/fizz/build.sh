#!/usr/bin/env bash
set -euxo pipefail

cmake -S fizz -B build -G Ninja ${CMAKE_ARGS} \
  -DCMAKE_CXX_STANDARD=20 \
  -DBUILD_SHARED_LIBS=ON \
  -DBUILD_TESTS=OFF \
  -DBUILD_EXAMPLES=OFF
cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
