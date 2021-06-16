#!/bin/sh

mkdir build
cd build

cmake ${CMAKE_ARGS} -GNinja .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_TESTING=ON

cmake --build . --config Release
cmake --build . --config Release --target install
ctest --output-on-failure -C Release
