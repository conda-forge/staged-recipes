#!/usr/bin/env bash
set -euxo pipefail

cmake -S . -B build -G Ninja \
  ${CMAKE_ARGS} \
  -DLIBSERIAL_ENABLE_TESTING=OFF \
  -DLIBSERIAL_BUILD_EXAMPLES=OFF \
  -DLIBSERIAL_PYTHON_ENABLE=OFF \
  -DLIBSERIAL_BUILD_DOCS=OFF \
  -DINSTALL_STATIC=OFF \
  -DINSTALL_SHARED=ON

cmake --build build --parallel "${CPU_COUNT}"

cmake --install build
