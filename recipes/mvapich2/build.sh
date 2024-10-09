#!/bin/bash

set -ex

unset F77 F90

export FFLAGS="-fallow-argument-mismatch ${FFLAGS}"

export CC=$(basename "$CC")
export CXX=$(basename "$CXX")
export FC=$(basename "$FC")

build_with_rdma=""
if [[ "$target_platform" == linux-* ]]; then
    echo "Build with RDMA support"
    build_with_rdma="--with-rdma=$PREFIX --enable-rdma-cm "
fi

./configure --prefix=$PREFIX \
            --with-device=ch4:ofi \
            --with-hwloc-prefix=$PREFIX \
            $build_with_rdma \
            --enable-fortran=all \
            --enable-romio \
            --enable-nemesis-shm-collectives \
            --disable-gl \
            --disable-nvml \
            --disable-cl \
            --disable-opencl \
            --disable-dependency-tracking \
            --with-sysroot \
            --enable-static=no

make -j"${CPU_COUNT}"
make install
