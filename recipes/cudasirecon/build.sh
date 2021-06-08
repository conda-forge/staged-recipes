#!/bin/bash
mkdir cmake_build
cd cmake_build

cmake ${CMAKE_ARGS} -DBUILD_MRC=OFF -DCMAKE_BUILD_TYPE=Release ../src
make
make install
