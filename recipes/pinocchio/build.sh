#!/bin/sh

mkdir build
cd build

cmake .. \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=$PREFIX -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DBUILD_WITH_URDF_SUPPORT=OFF
make
make install
