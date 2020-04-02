#!/bin/bash
./configure --prefix=${PREFIX} \
            ARCH="x86_64" \
            FOX_LIB="${PREFIX}/lib/libFoX_fsys.a ${PREFIX}/lib/libFoX_utils.a ${PREFIX}/lib/libFoX_common.a ${PREFIX}/lib/libFoX_wxml.a ${PREFIX}/lib/libFoX_wkml.a ${PREFIX}/lib/libFoX_sax.a ${PREFIX}/lib/libFoX_dom.a" \
            IFLAGS="-I${SRC_DIR}/include -I${PREFIX}/finclude -I${SRC_DIR}/S3DE/iotk/include/" \
            SCALAPACK_LIBS="${PREFIX}/lib/libscalapack.so" \
            LAPACK_LIBS="-L${PREFIX}/lib -llapack" \
            BLAS_LIBS="-L${PREFIX}/lib -lblas" \
            FFT_LIBS="${PREFIX}/lib/libfftw3.a" \
            CC="${CC}" \
            CPP="${CPP}" \
            LD="mpif90 -fopenmpi -fopenmp" \
            CFLAGS="${CFLAGS}" \
            FFLAGS="${FFLAGS}" \
            CPPFLAGS="${CPPFLAGS}" 
 make pwall
 make install
