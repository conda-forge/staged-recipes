#!/bin/bash

set -x

export CC=mpicc
export FC=mpifort

cmake -B build -S . \
      -DCMAKE_INSTALL_PREFIX=${PREFIX} \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_SHARED_LIBS=ON \
      -DYAC_ENABLE_PYTHON=ON \
      -DYAC_ENABLE_NETCDF=OFF \
      -DYAC_ENABLE_EXAMPLES=OFF \
      -DYAC_ENABLE_TOOLS=OFF \
      -DYAC_ENABLE_MPI_CHECKS=OFF \
      -DYAC_LAPACK_INTERFACE=system \
      -DPython3_EXECUTABLE=${PYTHON} \
      -DPython3_FIND_STRATEGY=LOCATION

cmake --build build -j ${CPU_COUNT}

cmake --install build
