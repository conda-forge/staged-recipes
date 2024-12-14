#!/bin/bash

set -ex

cd $SRC_DIR/psmpi

./autogen.sh

mkdir -p build
cd build

../configure --prefix=$PREFIX \
             --with-confset=devel \
             --with-pscom-allin=$SRC_DIR/pscom \
             --with-hwloc=$PREFIX \
             --with-pmix=$PREFIX \
             --enable-msa-awareness \
             --enable-threading \
             --enable-cxx \
	     --disable-fortran

make -j"${CPU_COUNT}"

make install

