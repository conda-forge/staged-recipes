#!/bin/bash
export FCFLAGS=${FFLAGS}

./configure \
--with-fft-libs=-lfftw \
--with-fft-path=${PREFIX}/lib \
--with-fft-libdir=${PREFIX}/lib \
--with-fft-includedir=${PREFIX}/include \
--with-netcdf-libs=-lnetcdf \
--with-netcdf-path=${PREFIX}/lib \
--with-netcdf-libdir=${PREFIX}/lib \
--with-netcdf-includedir=${PREFIX}/include \
--with-netcdff-libs=-lnetcdff \
--with-netcdff-path=${PREFIX}/lib \
--with-netcdff-libdir=${PREFIX}/lib \
--with-netcdff-includedir=${PREFIX}/include \
--with-libxc-libs=-llibxc \
--with-libxc-path=${PREFIX}/lib \
--with-libxc-libdir=${PREFIX}/lib \
--with-libxc-includedir=${PREFIX}/include \
--with-mpi-libs=-lmpi \
--with-mpi-path=${PREFIX}/lib \
--with-mpi-libdir=${PREFIX}/lib \
--with-mpi-includedir=${PREFIX}/include \ 
FC="${FC}" CC="${CC}" MPIFC=mpifort
make yambo ypp p2y
make install
