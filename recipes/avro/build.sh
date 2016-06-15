#!/bin/bash

mkdir build
cd build
echo $PREFIX

cmake .. \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -SNAPPY_ROOT_DIR=$PREFIX \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo

make # VERBOSE=1
make test
make install
