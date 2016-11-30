#!/bin/bash
mkdir build
cd build

cmake -DBACKWARD_TESTS=True -DCMAKE_PREFIX_PATH=$PREFIX -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX ..
make -j${CPU_COUNT}
ctest -V
make install
