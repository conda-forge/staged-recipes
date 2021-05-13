#!/bin/bash

export CPP="${CC} -E -P"
export FPP="${FC} -E -P -cpp"
./configure \
    --enable-openmp \
    --with-fft-path="${PREFIX}" \
    --enable-hdf5-par-io \
    --with-hdf5-path="${PREFIX}" \
    --with-netcdf-path="${PREFIX}"
    #--enable-slepc-linalg \
    #--with-slepc-path="${PREFIX}" \
    #--with-petsc-path="${PREFIX}" \


make -j$CPU_COUNT all

mkdir -p ${PREFIX}/bin
cp -r bin/* ${PREFIX}/bin
mkdir -p ${PREFIX}/lib
cp -r lib/external/*/*/lib/*.* ${PREFIX}/lib
