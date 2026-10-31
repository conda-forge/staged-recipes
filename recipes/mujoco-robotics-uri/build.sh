#!/usr/bin/env bash
set -euxo pipefail

cmake -S . -B build -G Ninja ${CMAKE_ARGS} \
    -DBUILD_TESTING=OFF
cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
