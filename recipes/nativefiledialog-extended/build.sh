#!/bin/sh

set -ex

mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja \
  -B . \
  -S .. \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  -DBUILD_SHARED_LIBS:BOOL=ON \
  -DNFD_BUILD_TESTS:BOOL=OFF

# build
cmake --build . --parallel ${CPU_COUNT}

# install
cmake --build . --parallel ${CPU_COUNT} --target install
