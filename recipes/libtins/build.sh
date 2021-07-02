#!/bin/bash

mkdir build
cd build

cmake ${CMAKE_ARGS} -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_INSTALL_LIBDIR=lib -DLIBTINS_BUILD_SHARED=ON ..
make -j${CPU_COUNT}
ctest -VV --output-on-failure
make install
