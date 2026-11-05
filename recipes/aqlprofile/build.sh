#!/bin/bash

set -xeuo pipefail

cmake -S . -B build -G Ninja \
    ${CMAKE_ARGS} \
    -DFETCHCONTENT_FULLY_DISCONNECTED=ON \
    -DAQLPROFILE_BUILD_TESTS=OFF \
    -DAQLPROFILE_INSTALL_TESTS=OFF

cmake --build build --parallel "${CPU_COUNT}"
cmake --install build
