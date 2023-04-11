#!bin/bash
mkdir build
  cd build
  cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    ..
  make -j${{ env.NUM_CPUS }}
  make install