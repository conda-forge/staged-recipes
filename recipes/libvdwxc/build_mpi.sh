#!/bin/sh

mkdir build && cd build

../configure --prefix=$PREFIX --disable-static CC=mpicc FC=mpifort CFLAGS="$CFLAGS -O3 -ffast-math -funroll-loops" FCFLAGS="$CFLAGS -O3 -ffast-math -funroll-loops" --with-fftw3=$PREFIX --with-mpi=$PREFIX

make -j$CPU_COUNT
make check
make install

# Removes binaries built and used by `make check` 
rm -rf $PREFIX/bin/libvdw_*test
rm -rf $PREFIX/bin/libvdw_*test
