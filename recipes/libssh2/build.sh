#!/bin/bash

mkdir build && cd build

cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DBUILD_SHARED_LIBS=OFF
cmake --build . --config Release --target install

cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DBUILD_SHARED_LIBS=ON
cmake --build . --config Release --target install

if [ -d $PREFIX/lib64 ];then
    rm -rf $PREFIX/lib64/pkgconfig
    mv $PREFIX/lib64/* $PREFIX/lib
fi
