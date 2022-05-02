#!/usr/bin/env bash
set -ex

cmake \
    ${CMAKE_ARGS} \
    -B _build -G Ninja \
    -DSCINE_MARCH=""
cmake --build _build
ctest --test-dir _build --output-on-failure
cmake --install _build
