#!/bin/sh

mkdir build && cd build

cmake ${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DBUILD_SHARED_LIBS=ON \
      -DVulkan_FOUND=OFF \
      -DVULKAN_INCOMPATIBLE=ON \
      -DDYNAMIC_LOADER=ON \
      -DFALLBACK_CONFIG_DIRS=$PREFIX/etc/xdg \
      -DFALLBACK_DATA_DIRS=$PREFIX/share \
      -DHAVE_FILESYSTEM_WITHOUT_LIB=OFF \
      $SRC_DIR

make -j${CPU_COUNT}
make install