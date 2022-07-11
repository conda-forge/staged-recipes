#!/usr/bin/env bash
set -ex

echo "**************** F R E E F E M  B U I L D  S T A R T S  H E R E ****************"

autoreconf -i

export FFLAGS=-Wno-argument-mismatch

./configure \
    --with-hdf5=$PREFIX \
    --enable-optim \
    --prefix=$PREFIX \
    --enable-debug \
    --with-mpi=no \
    --with-nlopt=$PREFIX \
    --with-hdf5=$PREFIX \
    # --disable-scalapack \
    # --enable-download \

make -j $CPU_COUNT

make install

#make check #-j$CPU_COUNT

echo "**************** F R E E F E M  B U I L D  E N D S  H E R E ****************"
