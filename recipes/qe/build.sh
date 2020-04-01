#!/bin/bash
./configure ARCH="x86_64" LIBDIRS="${PREFIX} ${BUILD_PREFIX} ${PREFIX}/lib ${BUILD_PREFIX}/lib" FOX_LIB="${PREFIX}/lib -lFoX_dom -lFoX_sax -lFoX_wxml -lFoX_common -lFoX_utils -lFoX_fsys" SCALAPACK_LIBS="${PREFIX}/lib/libscalapack.so" LAPACK_LIBS="${PREFIX}/lib/liblapack.so" BLAS_LIBS="${PREFIX}/lib/libopenblas.a" FFT_LIBS="${PREFIX}/lib/libfftw3.a" CC="${CC}" CPP="${CPP}" LD="mpif90 -fopenmpi" CFLAGS="${CFLAGS}" FFLAGS="${FFLAGS}" CPPFLAGS="${CPPFLAGS}" 
make all
