#!/bin/bash

mkdir -p build
cd build/

ls -l ${CONDA_PREFIX}/lib/libRDKit*

cmake -DCMAKE_BUILD_TYPE=Release \
    -DRDKIT_DIR=${CONDA_PREFIX} \
    -DUSE_PYTHON=ON \
    -DCMAKE_INSTALL_PREFIX=${CONDA_PREFIX} \
    ..

make
make install
