#!/bin/bash

mkdir build
cd build

cmake ${CMAKE_ARGS} ..
make -j${CPU_COUNT}
make install
