#!/bin/sh

mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja -DSPIRV_REFLECT_SHARED_LIB=ON .. 

cmake --build . --config Release
cmake --build . --config Release --target install
