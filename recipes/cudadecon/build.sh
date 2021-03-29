#!/bin/bash

mkdir build && cd build
cmake ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release ../src
make
make install
