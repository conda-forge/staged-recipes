#!/bin/bash

mkdir build && cd build

cmake \
  -DCMAKE_PREFIX_PATH="$PREFIX" \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DCMAKE_BUILD_TYPE="Release"  \
  -DBUILD_SHARED_LIBS=ON \
  -DNETWORKIT_EXT_TLX="$CONDA_PREFIX" \
  ..
make -j$CPU_COUNT
make install
