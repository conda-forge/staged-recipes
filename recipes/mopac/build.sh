#/usr/bin/env bash

set -ex

cmake -Bbuild -GNinja \
  ${CMAKE_ARGS} \
  -DCMAKE_BUILD_TYPE=Release \
  -DBLA_VENDOR=Generic

cmake --build build
cmake --install build
