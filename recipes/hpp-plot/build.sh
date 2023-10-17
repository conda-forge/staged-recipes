#!/bin/sh

mkdir build
cd build
cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      ${CMAKE_ARGS}
make -j${CPU_COUNT} 
make install
