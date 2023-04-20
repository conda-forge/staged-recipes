#!/bin/bash
mkdir build
cd build

cmake ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release ..
make -j${CPU_COUNT}
make install
