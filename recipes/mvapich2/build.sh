#!/bin/bash

set -ex

unset F77 F90

export FFLAGS="-fallow-argument-mismatch ${FFLAGS}"

export CC=$(basename "$CC")
export CXX=$(basename "$CXX")
export FC=$(basename "$FC")

./configure --prefix=$PREFIX \
            --enable-fast=none \
            --enable-g=all \
            --with-device=ch4:ofi \
            --with-hwloc-prefix=$PREFIX \
            --with-rdma=$PREFIX \
            --enable-fortran=all \
            --enable-romio \
            --enable-rdma-cm \
            --enable-nemesis-shm-collectives \
            --disable-gl \
            --disable-nvml \
            --disable-cl \
            --disable-opencl \
            --disable-dependency-tracking \
	    --with-sysroot \
            --enable-shared \
            --disable-static	    

make -j"${CPU_COUNT:-1}"
make install
