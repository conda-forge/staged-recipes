#!/bin/bash

mkdir build
cd build

cmake \
  .. \
  -DENABLE_BITSHUFFLE_PLUGIN=yes \
  -DENABLE_LZ4_PLUGIN=no \
  -DENABLE_BZIP2_PLUGIN=no \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DCMAKE_INSTALL_PREFIX=$PREFIX

make install
