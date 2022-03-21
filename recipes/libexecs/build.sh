#!/bin/bash

set -ex

mkdir build
cd build

cmake ${CMAKE_ARGS} ..
exit 1
cmake --build . -j "$CPU_COUNT"
cmake --build . --target install
