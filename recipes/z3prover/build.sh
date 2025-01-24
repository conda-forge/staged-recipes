#!/usr/bin/env bash

set -xe

mkdir -p build && cd build

cmake .. -G "Ninja" \
    ${CMAKE_ARGS} \
    -DZ3_BUILD_LIBZ3_SHARED=TRUE \
    -DZ3_INCLUDE_GIT_DESCRIBE=FALSE \
    -DZ3_INCLUDE_GIT_HASH=FALSE \
    -DZ3_BUILD_DOCUMENTATION=FALSE
ninja install
