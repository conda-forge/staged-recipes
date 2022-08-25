#!/bin/bash
rm -rf build
mkdir build
cd build
cmake ${CMAKE_ARGS} -GNinja -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_PREFIX_PATH=$PREFIX -DUUID_BUILD_TESTS=OFF -S .. -B .
ninja
ninja install
