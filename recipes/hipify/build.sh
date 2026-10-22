#!/bin/bash

set -xeuo pipefail

cmake -S . -B build -G Ninja ${CMAKE_ARGS} \
    -DFETCHCONTENT_FULLY_DISCONNECTED=ON \
    -DHIPIFY_CLANG_TESTS=OFF \
    -DHIPIFY_INSTALL_CLANG_HEADERS=OFF
cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
