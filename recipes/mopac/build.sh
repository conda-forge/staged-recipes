#/usr/bin/env bash

set -ex

cmake -Bbuild -GNinja \
  ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release

cmake --build build
cmake --install build
