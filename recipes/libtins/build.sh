#!/bin/bash

mkdir build
cd build

cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_INSTALL_LIBDIR=lib -DLIBTINS_BUILD_SHARED=0 ..
make -j${CPU_COUNT}
ctest -VV --output-on-failure
make install
