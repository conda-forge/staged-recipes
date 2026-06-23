#!/usr/bin/env bash
set -euo pipefail

cmake -S . -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DLLHTTP_BUILD_SHARED_LIBS=ON \
  -DLLHTTP_BUILD_STATIC_LIBS=OFF

cmake --build build -j"${CPU_COUNT:-1}"
cmake --install build
