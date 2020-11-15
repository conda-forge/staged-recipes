#!/bin/bash
./configure \
--with-fftw=${PREFIX}/lib \
--with-netcdf-lib=${PREFIX}/lib \
--with-netcdf-include=${PREFIX}/include \
--with-blas=${PREFIX}/lib -lblas \
--with-lapack=${PREFIX}/lib -llapack \
${PREFIX}
make yambo ypp interfaces
make install
