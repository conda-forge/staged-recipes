#!/usr/bin/env bash
mkdir build
cd build
cmake -DBUILD_ZFPY=ON -DCMAKE_INSTALL_PREFIX=$CONDA_PREFIX ..
make
make install
