#!/usr/bin/env bash

mkdir build && cd build

cmake -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    ../source

cmake --build . --target install -j${CPU_COUNT}
