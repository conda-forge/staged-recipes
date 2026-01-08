#!/bin/bash
set -ex

rm -rf build

cmake ${CMAKE_ARGS} \
  -B build \
  -S . \
  -G Ninja \
  -DCMAKE_INSTALL_INCLUDEDIR="include" \
  -DTIGHT_INCLUSION_TOPLEVEL_PROJECT=OFF \
  -DCMAKE_BUILD_TYPE:STRING=Release

# build
cmake --build build --parallel ${CPU_COUNT}

# install
cmake --build build --parallel ${CPU_COUNT} --target install
