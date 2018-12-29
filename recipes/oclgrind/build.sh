#!/bin/bash

mkdir build
cd build

cmake .. \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_PREFIX_PATH=${PREFIX} \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DLLVM_DIR=${PREFIX}/lib/cmake/llvm

make -j${CPU_COUNT}
make install
make test

mkdir -p ${PREFIX}/etc/OpenCL/vendors
cp oclgrind.icd ${PREFIX}/etc/OpenCL/vendors/
