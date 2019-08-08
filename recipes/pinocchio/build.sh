#!/bin/sh

mkdir build
cd build

cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DBUILD_WITH_URDF_SUPPORT=ON \
      -DBUILD_WITH_COLLISION_SUPPORT=ON

make -j${CPU_COUNT}
make install
