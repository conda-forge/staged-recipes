#!/usr/bin/env bash
set -euxo pipefail

cmake -S . -B build -G Ninja ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DUUID_BUILD_TESTS=OFF \
    -DUUID_ENABLE_INSTALL=ON \
    -DUUID_SYSTEM_GENERATOR=OFF \
    -DUUID_TIME_GENERATOR=OFF \
    -DUUID_USING_CXX20_SPAN=OFF
cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
