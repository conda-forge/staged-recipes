#!/usr/bin/env bash

# This was required for the local docker build to work.
git config --global --add safe.directory '*'

mkdir build
cd build

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

cmake ${CMAKE_ARGS} \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
		..

cmake --build . -- -j$(( CPU_COUNT>4 ? 4 : CPU_COUNT ))
cmake --build . --target install
