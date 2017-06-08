#!/bin/sh

mkdir .deps
cd .deps
cmake ../third-party
make
cd ..

mkdir build
cd build
cmake .. \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DENABLE_BUILD_TYPE=Release
make -j$CPU_COUNT
make install
