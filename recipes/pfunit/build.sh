#!/bin/bash

mkdir build
cd build

cmake \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DBUILD_SHARED_LIBS=ON \
    -DSKIP_ESMF=ON \
    -DSKIP_FHAMCREST=ON \
    -DSKIP_MPI=ON \
    -DSKIP_OPENMP=ON \
    -DSKIP_ROBUST=ON \
    ..

# -DCMAKE_INSTALL_LIBDIR=lib \

make -j"${CPU_COUNT}" install

