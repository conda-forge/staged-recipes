#!/bin/bash

mkdir -p build
cd build/

cmake -DCMAKE_BUILD_TYPE=Release \
    -DRDKIT_DIR=${PREFIX} \
    -DUSE_PYTHON=ON \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    ..

make -j$CPU_COUNT
make install
