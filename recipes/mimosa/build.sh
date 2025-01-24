#!/bin/bash

#CMAKE_PLATFORM_FLAGS+=(-DCMAKE_TOOLCHAIN_FILE="${RECIPE_DIR}/cross-linux.cmake")

mkdir cmake_build && cd cmake_build
#echo ${PREFIX} > cdprf
cmake -DCMAKE_PREFIX_PATH=${PREFIX} -DCMAKE_INSTALL_PREFIX=${PREFIX} -DUSE_CPLEX=0 ..
#cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} ${CMAKE_PLATFORM_FLAGS[@]} -DUSE_CPLEX=0 ..
#cmake -DCMAKE_PREFIX_PATH=${PREFIX} -DCMAKE_INSTALL_PREFIX=${PREFIX} ${CMAKE_PLATFORM_FLAGS[@]} -DUSE_CPLEX=0 ..
#cmake -DUSE_CPLEX=0 ..

make
make install

cd .. && rm -r cmake_build
