#!/usr/bin/env bash

set -euo pipefail

cmake -GNinja -S . -B build \
    $CMAKE_ARGS \
    -DENABLE_VULKAN=ON \
    -DENABLE_IMAGEMAGICK7=ON \
    -DENABLE_IMAGEMAGICK6=OFF \
    -DCMAKE_INSTALL_SYSCONFDIR="${PREFIX}/etc"
cmake --build build
cmake --install build
