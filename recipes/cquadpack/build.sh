#!/bin/bash
mkdir build
cd build
cmake .. -DCMAKE_PREFIX_PATH=$PREFIX -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX
make -j$CPU_COUNT
ctest -C Release --output-on-failure
make install
