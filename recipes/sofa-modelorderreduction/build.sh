#!/bin/sh

set -ex

mkdir build
cd build

cmake ${CMAKE_ARGS} .. \
  -DCOSSERATPLUGIN_BUILD_TESTS=OFF

# build
cmake --build . --parallel ${CPU_COUNT} --verbose

# install 
cmake --build . --parallel ${CPU_COUNT} --verbose --target install

# test
ctest --parallel ${CPU_COUNT} --verbose