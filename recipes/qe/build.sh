#!/bin/bash
./configure --prefix=${PREFIX} \
            ARCH="x86_64" \
            FOX_LIB="-L${PREFIX}/lib -lFoX_dom -lFoX_sax -lFoX_wxml -lFoX_common -lFoX_utils -lFoX_fsys " \
            IFLAGS="-I${SRC_DIR}/include -I${PREFIX}/finclude -I${SRC_DIR}/S3DE/iotk/include/" \
            SCALAPACK_LIBS="-L${PREFIX}/lib -lscalapack" \
            LAPACK_LIBS="-L${PREFIX}/lib -llapack" \
            BLAS_LIBS="-L${PREFIX}/lib -lblas" \
            FFT_LIBS="-L${PREFIX}/lib -lfftw3" \
            CC="${CC}" \
            CPP="${CPP}" \
            LD="mpif90 -fopenmpi -fopenmp" \
            CFLAGS="${CFLAGS}" \
            FFLAGS="${FFLAGS}" \
            CPPFLAGS="${CPPFLAGS}" 
 make pwall
 make install
