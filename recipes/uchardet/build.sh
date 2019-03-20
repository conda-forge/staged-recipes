#!/bin/bash
set -ex

mkdir -p build
cd build
cmake -DLIB_INSTALL_DIR="${PREFIX}/lib" \
  -DCMAKE_BUILD_PREFIX="${PREFIX}" \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_BUILD_TYPE=Release \
  ..
make -j "${CPU_COUNT}"
make install

ls -l $PREFIX/lib64
