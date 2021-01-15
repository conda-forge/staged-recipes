#!/usr/bin/env bash

mkdir build
cd build

cmake \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DUSE_MPI=OFF \
    ../src

make -j${CPU_COUNT} install

