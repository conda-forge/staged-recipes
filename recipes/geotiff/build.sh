#!/bin/bash

cmake -D CMAKE_PREFIX_PATH=$PREFIX \
      -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D WITH_PROJ4=ON \
      -D WITH_ZLIB=ON \
      -D WITH_JPEG=ON \
      -D WITH_TIFF=ON \
      .

make
make install

