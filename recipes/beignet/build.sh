#!/bin/bash

mkdir build
cd build

cmake \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DOCL_ICD_INSTALL_PREFIX=$PREFIX/etc/OpenCL/vendors/ \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DCMAKE_INSTALL_LIBDIR=lib \
  ..

make -j${CPU_COUNT}
# can't run tests without an Intel graphics card
# make utest_run
# ./utests/utest_run
make install

# Remove CL headers as they are in ocl-icd
rm -rf $PREFIX/include/CL
