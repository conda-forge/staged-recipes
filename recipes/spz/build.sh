#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

cmake -S ${SRC_DIR} -B build -G Ninja \
      -DBUILD_SHARED_LIBS=ON \
      ${CMAKE_ARGS}

cmake --build build -j${CPU_COUNT}
cmake --install build
