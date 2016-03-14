#!/bin/bash

cd trunk
cmake -D CMAKE_INSTALL_PREFIX=$PREFIX \
-D CMAKE_SKIP_RPATH=ON \
-D HDF5_INCLUDE_DIR=$PREFIX/include \
-D HDF5_LIB_PATH=$PREFIX/lib \
.

make
make install
