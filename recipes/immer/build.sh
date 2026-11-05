#!/usr/bin/env bash
set -euxo pipefail

cmake -S . -B build -G Ninja ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -Dimmer_BUILD_TESTS=OFF \
    -Dimmer_BUILD_EXAMPLES=OFF \
    -Dimmer_BUILD_DOCS=OFF \
    -Dimmer_BUILD_EXTRAS=OFF
cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
