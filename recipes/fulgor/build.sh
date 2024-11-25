#!/bin/sh

mkdir build
cd build

cmake ${CMAKE_ARGS} .. \
      -DCMAKE_BUILD_TYPE=Release
make -j $(($CPU_COUNT/2))
cmake --build . --target install
