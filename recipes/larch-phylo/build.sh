#!/bin/bash

git config url."https://github.com/".insteadOf "git@github.com:"
git config url."https://github.com/".insteadOf "ssh://git@github.com/"
git submodule update --init --recursive

rm -rf build
mkdir build
cd build

export CMAKE_NUM_THREADS=${CPU_COUNT}
cmake $CMAKE_ARGS -DCMAKE_POLICY_VERSION_MINIMUM=3.5 -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-Wno-c++20-extensions" ..
make -j${CPU_COUNT}
make install
