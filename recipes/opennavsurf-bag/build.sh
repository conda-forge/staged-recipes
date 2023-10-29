#!/bin/bash

set -ex # Abort on error.

mkdir build

# Configure CMake build
cmake ${CMAKE_ARGS} -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -B build -S . \
  -DBUILD_SHARED_LIBS:BOOL=ON \
  -DBAG_BUILD_TESTS:BOOL=OFF \
  -DBAG_BUILD_PYTHON:BOOL=OFF

# Build C++
cmake --build build -j ${CPU_COUNT} --config Release
