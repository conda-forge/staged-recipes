#!/bin/sh

mkdir build
cd build

cmake .. \
      ${CMAKE_ARGS} \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DPYTHON_EXECUTABLE=$PYTHON

make -j${CPU_COUNT} 
make install
