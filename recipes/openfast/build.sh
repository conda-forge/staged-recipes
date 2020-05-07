#!/bin/bash

mkdir build
cd build

cmake \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DGIT_DESCRIBE=${GIT_DESCRIBE_HASH} \
    ..

make -j"${CPU_COUNT}" install
