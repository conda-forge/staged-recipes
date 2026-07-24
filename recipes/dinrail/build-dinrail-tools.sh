#!/usr/bin/env bash
set -euxo pipefail

cmake -S src/cli -B build-dinrail-tools -GNinja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  ${CMAKE_ARGS}
cmake --build build-dinrail-tools -j "${CPU_COUNT}"
cmake --install build-dinrail-tools
