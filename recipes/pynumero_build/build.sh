#!/bin/bash -e

mkdir build
cd build

cmake .. -DMP_PATH=$PREFIX -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=$PREFIX

make 
make install
