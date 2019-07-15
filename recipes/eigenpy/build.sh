#!/bin/sh

git submodule update --init

mkdir build
cd build

PKG_CONFIG_PATH=$PREFIX/share/pkgconfig cmake .. \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=$PREFIX -DCMAKE_INSTALL_PREFIX=$PREFIX
make
make install
