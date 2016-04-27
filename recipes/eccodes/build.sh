#!/usr/bin/env bash

mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PREFIX \
         -DENABLE_JASPER=1 \
         -DENABLE_NETCDF=1 \
         -DENABLE_PNG=1 \
         -DENABLE_PYTHON=0 \
         -DENABLE_FORTRAN=0

make
export ECCODES_TEST_VERBOSE_OUTPUT=1
ctest
make install