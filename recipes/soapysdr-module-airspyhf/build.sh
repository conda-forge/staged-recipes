#!/usr/bin/env bash

set -ex

mkdir build
cd build

cmake ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release ..
cmake --build . --config Release -- -j${CPU_COUNT}
cmake --build . --config Release --target install
