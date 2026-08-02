#!/bin/sh

mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja -DBUILD_SHARED_LIBS=ON .. 

cmake --build . --config Release
cmake --build . --config Release --target install
