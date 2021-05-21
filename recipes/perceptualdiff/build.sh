#!/bin/bash

# From Makefile

mkdir -p build
cmake -H. -Bbuild \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DCMAKE_INSTALL_RPATH=${PREFIX}/lib \
  -DCMAKE_MACOSX_RPATH=ON \

make --directory=build
make --directory=build install
