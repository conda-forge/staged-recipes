#!/usr/bin/env bash
set -ex

echo "**************** F R E E F E M  B U I L D  S T A R T S  H E R E ****************"

autoreconf -i
## Required to make linker look in correct prefix
export LIBRARY_PATH="${PREFIX}/lib"
export LD_LIBRARY_PATH="${PREFIX}/lib"

./configure --prefix=$PREFIX \
            --enable-optim \
            --enable-debug \
            --without-mpi \
            --disable-fortran

make -j $CPU_COUNT
make install
rm $PREFIX/lib/ff++/${PKG_VERSION}/lib/*.so # to avoid conda DSO errors
rm $PREFIX/lib/ff++/${PKG_VERSION}/lib/*.a # static libraries are not allowed
make check -j $CPU_COUNT check

echo "**************** F R E E F E M  B U I L D  E N D S  H E R E ****************"
