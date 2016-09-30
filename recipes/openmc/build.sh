#!/bin/bash
set -x
set -e

export FC=gfortran
#rm -f cmake/Modules/FindHDF5.cmake
mkdir -p build
cd build
cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release ..
make -j "${CPU_COUNT}"
make install
