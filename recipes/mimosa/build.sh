#!/bin/bash

mkdir cmake_build && cd cmake_build
cmake ${CMAKE_ARGS} -DUSE_CPLEX=0 ..

cmake --build . --target install

