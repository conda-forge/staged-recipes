#!/bin/bash

# Build static.
cmake -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D CMAKE_INSTALL_LIBDIR:PATH=$PREFIX/lib \
      -D ENABLE_DAP=ON \
      -D ENABLE_HDF4=ON \
      -D ENABLE_NETCDF_4=ON \
      -D BUILD_SHARED_LIBS=OFF \
      -D ENABLE_TESTS=ON \
      -D BUILD_UTILITIES=ON \
      -D ENABLE_DOXYGEN=OFF \
      $SRC_DIR
make
# ctest  # Save some time.
make install

# Build shared.
cmake -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D CMAKE_INSTALL_LIBDIR:PATH=$PREFIX/lib \
      -D ENABLE_DAP=ON \
      -D ENABLE_HDF4=ON \
      -D ENABLE_NETCDF_4=ON \
      -D BUILD_SHARED_LIBS=ON \
      -D ENABLE_TESTS=ON \
      -D BUILD_UTILITIES=ON \
      -D ENABLE_DOXYGEN=OFF \
      $SRC_DIR
make
ctest
make install
