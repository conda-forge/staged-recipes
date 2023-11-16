#!/bin/bash
set -x
set -e

mkdir -p build
cd build

cmake \
    -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
    ../src \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_BUILD_TYPE=Release \
    -G "Unix Makefiles" \
    ${CMAKE_ARGS}

make -j${CPU_COUNT:-1}
make test
make install

