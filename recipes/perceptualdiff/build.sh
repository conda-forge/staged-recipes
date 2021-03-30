#!/bin/bash

mkdir build
cd build
cmake .. \
        -DCMAKE_INSTALL_PREFIX=${CONDA_PREFIX} \
        -DCMAKE_INSTALL_RPATH=${CONDA_PREFIX}/lib \
        -DCMAKE_MACOSX_RPATH=ON
make
make install
