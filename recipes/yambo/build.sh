#!/bin/bash
./configure \
--enable-netcdf-classic \
--with-fft-libs=-lfftw \
--with-fft-path=${PREFIX}/lib \
--with-fft-libdir=${PREFIX}/lib \
--with-fft-includedir=${PREFIX}/include \
${PREFIX}
make yambo ypp interfaces
make install
