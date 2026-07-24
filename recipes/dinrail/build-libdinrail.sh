#!/usr/bin/env bash
set -euxo pipefail

cmake -S src/core -B build-libdinrail -GNinja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  ${CMAKE_ARGS}
cmake --build build-libdinrail -j "${CPU_COUNT}"
cmake --install build-libdinrail
