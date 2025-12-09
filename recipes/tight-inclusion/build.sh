#!/bin/bash
set -ex

rm -rf build

mkdir build
cd build

cmake ${CMAKE_ARGS} \
  -B . \
  -S .. \
  -DCMAKE_INSTALL_INCLUDEDIR="include" \
  -DTIGHT_INCLUSION_TOPLEVEL_PROJECT=OFF \
  -DCMAKE_BUILD_TYPE:STRING=Release

# build
cmake --build . --parallel ${CPU_COUNT}

# install
cmake --build . --parallel ${CPU_COUNT} --target install
