#!/bin/bash

mkdir cmake_build && cd cmake_build
cmake -DCMAKE_PREFIX_PATH=${PREFIX} -DCMAKE_INSTALL_PREFIX=${PREFIX} -DUSE_CPLEX=0 ..

cmake --build . --target install

