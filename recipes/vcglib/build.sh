#!/bin/bash

set -euxo pipefail

cmake ${SRC_DIR} \
    ${CMAKE_ARGS} \
    -B build \
    -DVCG_ALLOW_BUNDLED_EIGEN=OFF \
    -DVCG_ALLOW_SYSTEM_EIGEN=ON

cmake --build build --parallel

cmake --build build --parallel --target install
