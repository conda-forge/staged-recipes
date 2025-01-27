#!/usr/bin/env bash

set -xe

mkdir -p build
cd build
cmake .. -G "Ninja" ${CMAKE_ARGS}
ninja install

