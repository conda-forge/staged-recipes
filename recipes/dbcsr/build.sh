#!/usr/bin/env bash

set -xe

cmake -S . -B build \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DBUILD_TESTING=OFF \
    -DWITH_EXAMPLES=OFF \
    ${CMAKE_ARGS}

cmake --build build --target install -j"${CPU_COUNT}" -v