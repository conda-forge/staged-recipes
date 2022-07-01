#!/usr/bin/env/ bash

set -ex

pushd quickcpplib
cmake \
  ${CMAKE_ARGS} \
  -B _build -G "Unix Makefiles" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PWD/_install
cmake --build _build
cmake --install _build
popd

cmake \
  ${CMAKE_ARGS} \
  -B _build \
  -DCMAKE_BUILD_TYPE=Release \
  -Dquickcpplib_DIR=$PWD/quickcpplib/_install/lib/cmake/quickcpplib

cmake --build _build
cmake --install _build
