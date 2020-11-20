#!/bin/bash

mkdir build
cd build

echo "${CONDA_PREFIX}"
echo ${CONDA_PREFIX}

cmake \
    -DCMAKE_INSTALL_PREFIX=${CONDA_PREFIX} \
    -DBUILD_SHARED_LIBS=ON \
    -DSKIP_ESMF=ON \
    -DSKIP_FHAMCREST=ON \
    -DSKIP_MPI=ON \
    -DSKIP_OPENMP=ON \
    -DSKIP_ROBUST=ON \
    ..

# -DCMAKE_INSTALL_LIBDIR=lib \

make -j"${CPU_COUNT}" install

