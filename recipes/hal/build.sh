#!/usr/bin/env bash

set -xe

mkdir -p build
cd build
cmake .. -G "Ninja" \
    -DUSE_VENDORED_PYBIND11=OFF \
    -DUSE_VENDORED_QUAZIP=OFF \
    -DUSE_VENDORED_IGRAPH=OFF \
    -DUSE_VENDORED_SPDLOG=OFF \
    -DHAL_VERSION_MAJOR=4 \
    -DHAL_VERSION_MINOR=4 \
    -DHAL_VERSION_PATCH=1 \
    ${CMAKE_ARGS}
ninja install

