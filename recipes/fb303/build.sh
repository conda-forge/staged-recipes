#!/usr/bin/env bash
set -euxo pipefail

cmake -S . -B build -G Ninja ${CMAKE_ARGS} \
  -DCMAKE_CXX_STANDARD=20 \
  -DBUILD_SHARED_LIBS=ON \
  -DPYTHON_EXTENSIONS=OFF
cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
