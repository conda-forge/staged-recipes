#!/bin/bash
mkdir cmake_build
cd cmake_build


CXXFLAGS="$CXXFLAGS -Wno-deprecated-declarations"
cmake ${CMAKE_ARGS} -DBUILD_MRC=OFF -DCMAKE_BUILD_TYPE=Release ../src
make
make install
