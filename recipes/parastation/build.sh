#!/bin/bash

set -ex

unset FFLAGS F77 F90 F95

export CC=$(basename "$CC")
export CXX=$(basename "$CXX")
export FC=$(basename "$FC")

cd $SRC_DIR/psmpi

./autogen.sh

mkdir -p build
cd build

../configure --prefix=$PREFIX \
             --with-confset=gcc \
             --enable-confset-overwrite \
             --with-pscom-allin=$SRC_DIR/pscom \
             --with-hwloc=$PREFIX \
             --with-pmix=$PREFIX \
             --enable-msa-awareness \
             --enable-threading

make -j"${CPU_COUNT}"

make install
