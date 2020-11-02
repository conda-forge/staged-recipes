#!/bin/sh

mkdir build
cd build
cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DUSE_QPOASES=FALSE
# Can be update when conda qpoases is available
make -j${CPU_COUNT} 
make install
