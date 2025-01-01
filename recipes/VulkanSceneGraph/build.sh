#!/bin/bash

set -exo pipefail

cmake $SRC_DIR \
  ${CMAKE_ARGS} \
  -G Ninja \
  -B build \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_BUILD_TYPE=Release

cmake --build build --parallel

cmake --install build --parallel
