#!/bin/bash

set -euxo pipefail

cmake -S . -B build -G Ninja \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    -DCMAKE_PREFIX_PATH="${PREFIX}" \
    -DCMAKE_BUILD_TYPE=Release \
    -DTIMG_VERSION_FROM_GIT=OFF

cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
