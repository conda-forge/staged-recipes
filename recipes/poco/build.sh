#!/bin/bash

mkdir cmake_build
cd cmake_build
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX ..

make -j${CPU_COUNT}
make install
