#!/bin/bash

mkdir build
cd build
if [ $(uname -m) = "i686" ]; then
  COMPILER32="-DCMAKE_C_FLAGS=-m32 -DCMAKE_CXX_FLAGS=-m32"
fi
cmake .. $COMPILER32 -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_PREFIX_PATH=$PREFIX
make -j2
make install
