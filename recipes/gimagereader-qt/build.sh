#!/bin/bash

mkdir build
cd build
cmake -G Ninja \
      ${CMAKE_ARGS} \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DINTERFACE_TYPE=qt5 \
      ..
cmake --build . -- -j${CPU_COUNT}
cmake --install .
