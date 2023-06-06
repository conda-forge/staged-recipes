#!/bin/sh

set -ex

mkdir build
cd build

cmake ${CMAKE_ARGS} -B . -S .. \
  -DSOFA_BUILD_TESTS=OFF \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DSOFA_ENABLE_LEGACY_HEADERS=OFF \

# build
cmake --build . --parallel ${CPU_COUNT} --verbose

# install 
cmake --build . --parallel ${CPU_COUNT} --verbose --target install

# test
ctest --parallel ${CPU_COUNT} --verbose