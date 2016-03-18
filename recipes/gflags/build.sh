#!/bin/bash

mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX -DINSTALL_HEADERS=on -DBUILD_SHARED_LIBS=on -DBUILD_TESTING=on
make
ctest
make install
