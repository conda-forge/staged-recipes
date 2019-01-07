#!/bin/sh
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX -DBUILD_CSM=OFF -DBUILD_TESTS=OFF ..
make install
