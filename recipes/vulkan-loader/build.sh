#!/bin/sh

mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja .. 

cmake --build . --config Release
cmake --build . --config Release --target install
