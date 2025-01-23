#!/usr/bin/env bash

set -xe

# python scripts/mk_make.py
mkdir -p build && cd build

cmake .. -G "Ninja" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DZ3_BUILD_LIBZ3_SHARED=TRUE \
    -DZ3_INCLUDE_GIT_DESCRIBE=FALSE \
    -DZ3_INCLUDE_GIT_HASH=FALSE \
    -DZ3_BUILD_DOCUMENTATION=FALSE
ninja install
