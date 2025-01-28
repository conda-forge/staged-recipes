#!/usr/bin/env bash

set -xe

cmake -S . -B build -DMOTIF_INCLUDE_DIR=$PREFIX/include ${CMAKE_ARGS}
cmake --build build --target install -j"${CPU_COUNT}"

