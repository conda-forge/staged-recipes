#!/usr/bin/env bash
set -ex

echo "**************** F R E E F E M  B U I L D  S T A R T S  H E R E ****************"

autoreconf -i
export FFLAGS=-fallow-argument-mismatch
# Required to make linker look in correct prefix
#export LIBRARY_PATH="${PREFIX}/lib"
#export LD_LIBRARY_PATH="${PREFIX}/lib"

./configure --prefix=$PREFIX \
            --enable-optim \
            --enable-debug \
            --disable-scotch \
            --without-mpi \
            --without-tetgen
            #--with-hdf5=$PREFIX/lib/libhdf5.so \
            #--with-hdf5-include=$PREFIX/include \
            #--with-blas=$BUILD_PREFIX/lib/libopenblas.so.0 \
            #--with-blas-include=$BUILD_PREFIX/include \
            #--without-arpack

make -j $CPU_COUNT
make -j # $CPU_COUNT check
make install

echo "**************** F R E E F E M  B U I L D  E N D S  H E R E ****************"
