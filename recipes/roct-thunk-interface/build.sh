#!/bin/bash

mkdir build
cd build


cmake \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_LIBDIR=lib \
  ..

make VERBOSE=1 -j${CPU_COUNT}
make install

# Copy include files
mkdir -p $PREFIX/include
cp $SRC_DIR/include/hsa* $PREFIX/include/

# Remove license file in weird directory
rm $PREFIX/libhsakmt/LICENSE.md
