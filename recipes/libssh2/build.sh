#!/bin/bash

mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX

cmake --build . --config Release --target install

if [ -d $PREFIX/lib64 ];then
    mv $PREFIX/lib64 $PREFIX/lib
fi
