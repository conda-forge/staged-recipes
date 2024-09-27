#!/bin/bash

set -ex

unset F90

export CC=${CC:-gcc}
export CXX=${CXX:-g++}
export FC=${FC:-gfortran}
export F77=${FC}
echo "Compiler versions: " ${CC} --version " " ${CXX} --version " "${FC} --version

export FFLAGS="-fallow-argument-mismatch ${FFLAGS}"

./configure --prefix=$PREFIX \
            --enable-fast=none \
            --enable-g=all \
            --with-device=ch4:ofi \
            --disable-gl \
            --disable-nvml \
            --disable-cl \
            --disable-opencl

make -j"${CPU_COUNT:-1}"
make install
