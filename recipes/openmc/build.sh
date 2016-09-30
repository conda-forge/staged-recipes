#!/bin/bash
set -x
set -e

export FC=gfortran
#export FCFLAGS="-funroll-all-loops -c -fpic -fdefault-real-8 -fdefault-double-8 -fdefault-integer-8"
rm -f cmake/Modules/FindHDF5.cmake
mkdir -p build
cd build
cmake -DCMAKE_INSTALL_PREFIX="${PREFIX}" -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_Fortran_FLAGS="-funroll-all-loops -c -fpic -fno-underscoring" \
  -DHDF5_ROOT="${PREFIX}" ..
make -j "${CPU_COUNT}"
make install

  #-DCMAKE_Fortran_FLAGS="-funroll-all-loops -c -fpic -fdefault-real-8 -fdefault-double-8 -fdefault-integer-8 -fno-underscoring" \
  #-DCMAKE_Fortran_FLAGS="${FCFLAGS}" \
