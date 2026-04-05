#!/bin/sh

set -ex

cmake ${CMAKE_ARGS} \
  -B build \
  -S . \
  -G Ninja \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DPython_EXECUTABLE:PATH=${PREFIX}/bin/python \
  -DPLUGIN_SOFAPYTHON=ON

# build
cmake --build build --parallel ${CPU_COUNT}

# install
cmake --install build