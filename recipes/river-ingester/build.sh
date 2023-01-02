#!/bin/bash

set -x -e
set -o pipefail

if [[ "${target_platform}" == osx-* ]]; then
    # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
    CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

cd cpp
mkdir -p build/release
cd build/release
cmake -G "Unix Makefiles" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DRIVER_BUILD_INGESTER=ON \
  -DRIVER_BUILD_TESTS=OFF \
  -DRIVER_INSTALL=ON \
  ${CMAKE_ARGS} \
  ../..
cd ingester
make
make install

