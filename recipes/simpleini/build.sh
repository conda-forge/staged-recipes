#!/bin/bash
set -ex

mkdir build
cd build

cmake ${CMAKE_ARGS} \
  -B . \
  -S .. \
  -G Ninja \
  -DBUILD_TESTING=OFF \
  -DCMAKE_BUILD_TYPE:STRING=Release

# build
cmake --build .

# install
cmake --build . --target install
