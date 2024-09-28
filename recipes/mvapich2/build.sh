#!/bin/bash

set -ex

unset F77 F90

export FFLAGS="-fallow-argument-mismatch ${FFLAGS}"

export CC=$(basename "$CC")
export CXX=$(basename "$CXX")
export FC=$(basename "$FC")

build_with_rdma=""
if [[ "$target_platform" == linux-* ]]; then
    echo "Build with UCX/UCC support"
    build_with_rdma="--with-rdma=$PREFIX --enable-rdma-cm "
fi

./configure --prefix=$PREFIX \
            --enable-fast=none \
            --enable-shared \
	    --with-sysroot \
            --enable-g=all \
            --with-device=ch4:ofi \
            --with-hwloc-prefix=$PREFIX \
            --enable-fortran=all \
            --enable-romio \
            --enable-nemesis-shm-collectives \
            --disable-dependency-tracking \
            --disable-opencl \
            --disable-static +
            --disable-nvml \
            --disable-cl \
            --disable-gl \
	    $build_with_rdma

make -j"${CPU_COUNT:-1}"
make install
