#!/bin/sh

mkdir build
cd build
cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_CXX_FLAGS=-std=c++17 \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DHPP_MANIPULATION_HAS_WHOLEBODY_STEP=FALSE \
      -DBUILD_TESTING=FALSE
# Can be updated with True HPP_MANIPULATION_HAS_WHOLEBODY_STEP with body step stack
make -j${CPU_COUNT} 
make install
