#!/usr/bin/env bash

set -ex

mkdir build
cd build

cmake ${CMAKE_ARGS} \
      -DCMAKE_BUILD_TYPE:STRING=Release \
      -GNinja \
      ..

cmake --build .

cmake --install .
