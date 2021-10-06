#!/bin/sh

mkdir -p "test/TokenizerTest/objects"
mkdir build
cd build
cmake ${CMAKE_ARGS} \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DFREETYPE_INCLUDE_DIR=${PREFIX}/include/freetype2 \
      -DPODOFO_BUILD_SHARED=1 \
      -DPODOFO_HAVE_JPEG_LIB=1 \
      -DPODOFO_HAVE_PNG_LIB=1 \
      -DPODOFO_HAVE_TIFF_LIB=1 \
      ..
make
make install
