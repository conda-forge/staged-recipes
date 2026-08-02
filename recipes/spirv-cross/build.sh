#!/bin/sh

mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja -DSPIRV_CROSS_SHARED=ON -DSPIRV_CROSS_ENABLE_TESTS=OFF .. 

cmake --build . --config Release
cmake --build . --config Release --target install
