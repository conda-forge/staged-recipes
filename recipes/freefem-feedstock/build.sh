#!/usr/bin/env bash
set -ex

echo "**************** F R E E F E M  B U I L D  S T A R T S  H E R E ****************"

autoreconf -i
export FFLAGS=-Wno-argument-mismatch
#./3rdparty/getall -a
./configure --with-hdf5=$PREFIX --enable-optim --prefix=$PREFIX --enable-debug #--disable-scalapack # --enable-download
make
make install
#make check #-j$CPU_COUNT

echo "**************** F R E E F E M  B U I L D  E N D S  H E R E ****************"
