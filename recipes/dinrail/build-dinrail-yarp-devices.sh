#!/usr/bin/env bash
set -euxo pipefail

cmake -S src/yarp-devices -B build-dinrail-yarp-devices -GNinja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  ${CMAKE_ARGS}
cmake --build build-dinrail-yarp-devices -j "${CPU_COUNT}"
cmake --install build-dinrail-yarp-devices
