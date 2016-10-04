#!/bin/bash
set -x
set -e

export FC=gfortran
mkdir -p build
cd build
cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DHDF5_ROOT="${PREFIX}" \
  ..
make -j "${CPU_COUNT}"
make install
