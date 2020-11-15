#!/bin/bash
./configure \
--enable-netcdf-classic \
--with-scalapack-libs=-lscalapack \
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
${PREFIX}
make yambo ypp interfaces
make install
