#!/usr/bin/env bash
set -euxo pipefail

cmake -S src/yarp-tools -B build-dinrail-yarp-tools -GNinja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  ${CMAKE_ARGS}
cmake --build build-dinrail-yarp-tools -j "${CPU_COUNT}"
cmake --install build-dinrail-yarp-tools
