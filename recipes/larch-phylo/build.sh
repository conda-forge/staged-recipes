#!/bin/bash

rm -rf build
mkdir build
cd build

export CMAKE_NUM_THREADS=${CPU_COUNT}
cmake $CMAKE_ARGS -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-Wno-c++20-extensions" ..
make -j${CPU_COUNT}
make install
