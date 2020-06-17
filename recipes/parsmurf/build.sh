#!/bin/sh
cd parSMURF
mkdir build
cd build
cmake src -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_LIBDIR=lib -DBUILD_SHARED_LIBS=ON
make -j 4
make install
