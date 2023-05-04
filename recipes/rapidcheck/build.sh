#!/bin/bash
mkdir build
cd build
cmake \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE:STRING=Release \
  ..
  
make
make install
