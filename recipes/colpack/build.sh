#!/bin/bash

mkdir build/cmake/work
cd build/cmake/work
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX ..
make -j${CPU_COUNT}
make install
