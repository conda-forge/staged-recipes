#!/usr/bin/env bash

set -ex

cmake -S . -B build ${CMAKE_ARGS} -GNinja -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel ${CPU_COUNT}
cmake --install build