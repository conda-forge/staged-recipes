#!/usr/bin/env bash
set -euxo pipefail

cmake -S src/devices -B build-dinrail-devices -GNinja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  ${CMAKE_ARGS}
cmake --build build-dinrail-devices -j "${CPU_COUNT}"
cmake --install build-dinrail-devices
