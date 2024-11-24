#!/bin/sh

mkdir build
cd build

cmake ${CMAKE_ARGS} .. \
      -G Ninja \
      -DCMAKE_BUILD_TYPE=Release
cmake --build . --parallel $(($CPU_COUNT/2))
cmake --build . --target install
