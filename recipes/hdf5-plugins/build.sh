#!/bin/bash

mkdir build
cd build

cmake \
  .. \
  -DENABLE_BITSHUFFLE_PLUGIN=yes \
  -DENABLE_LZ4_PLUGIN=yes \
  -DENABLE_BZIP2_PLUGIN=yes \
  -DCMAKE_INSTALL_PREFIX=$PREFIX

make install
