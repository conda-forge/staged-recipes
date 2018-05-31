#!/usr/bin/env bash

./autobuild
./configure --prefix=$PREFIX
make -j$CPU_COUNT
make install
#mkdir build && cd build
#cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX -DCMAKE_PREFIX_PATH=$PREFIX -DCMAKE_BUILD_TYPE=Release ..
#make install
