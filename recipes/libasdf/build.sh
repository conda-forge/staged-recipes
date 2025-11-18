#!/usr/bin/env bash

mkdir build
cd build
cmake .. \
    -DCMAKE_INSTALL_PREFIX=${CONDA_PREFIX} \
    -DENABLE_TESTING_CPP=YES \
    -DENABLE_TESTING_SHELL=YES

make install

