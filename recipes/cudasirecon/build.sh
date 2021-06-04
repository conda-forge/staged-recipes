#!/bin/bash

mkdir cmake_build
cd cmake_build
cmake ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release ..
make
make install
