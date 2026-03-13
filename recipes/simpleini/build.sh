#!/bin/bash
set -ex

cmake ${CMAKE_ARGS} \
  -B build \
  -S .. \
  -G Ninja \
  -DBUILD_TESTING=OFF \
  -DCMAKE_BUILD_TYPE:STRING=Release

# build
cmake --build build

# install
cmake --install build
