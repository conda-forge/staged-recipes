#!/bin/bash

./configure \
    --enable-slepc-linalg \
    --with-slepc-path="${PREFIX}" \
    --enable-hdf5-par-io \
    --with-hdf5-path="${PREFIX}" \
    --with-netcdf-path="${PREFIX}"


make all

make install
