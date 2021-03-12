#!/usr/bin/env bash

set -ex

mkdir build
cd build

cmake -D CMAKE_INSTALL_PREFIX:PATH=${PREFIX} \
      -D CMAKE_PREFIX_PATH:PATH=${PREFIX} \
      -D CMAKE_BUILD_TYPE:STRING=Release \
      ..

cmake --build .

cmake --install .
