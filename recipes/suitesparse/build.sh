#!/bin/bash

if [ "$(uname)" == "Linux" ]; then
  DYNAMIC_EXT=".so"

  # build using OpenBLAS
  BLAS='BLAS=-lopenblas -lgfortran'
  LAPACK='LAPACK=-lopenblas' # llapack'
fi

if [ "$(uname)" == "Darwin" ]; then
  DYNAMIC_EXT=".dylib"

  # if unspecified on OSX BLAS & LAPACK will be get to "-framework Accelerate"
  BLAS='' # 'BLAS=-lopenblas'
  LAPACK='' # 'LAPACK=-llapack'

  # some tests fail to link TBB unless $PREFIX/lib is added to rpath
  LDFLAGS="$LDFLAGS -Wl,-rpath,${PREFIX}/lib"
fi

# This recipe is currently building the version of METIS included with
# SuiteSparse.  An external METIS library can be used, but only the version
# included with SuiteSparse will work with the Matlab interface to METIS.
# (See the SuiteSparse README for more information)

# Notes:
#    For MKL, set MKLROOT=
#    To specify a fortran compiler, set F77=
#    To use external METIS lib, set MY_METIS_LIB=,  MY_METIS_INC=

# (optional) write out various make variable settings for debugging purposes
make config \
    $BLAS \
    $LAPACK \
    CUDA=no \
    TBB=-ltbb 2>&1 | tee make_config.txt

# enable TBB, disable CUDA
make $BLAS \
     $LAPACK \
     CUDA=no \
     TBB=-ltbb

# make install below fails to link libmetis unless it is copied to $PREFIX/lib
cp $SRC_DIR/lib/libmetis$DYNAMIC_EXT $PREFIX/lib

# have to specify CUDA=no to avoid attempts to link to libcudart, etc.
make install metis INSTALL_LIB=$PREFIX/lib \
             INSTALL_INCLUDE=$PREFIX/include \
             INSTALL_DOC=$PREFIX/suitesparse_docs \
             CUDA=no

if [ "$(uname)" == "Darwin" ]; then

  install_name_tool -change $SRC_DIR/lib/libmetis.dylib @rpath/libmetis.dylib $PREFIX/lib/libcholmod.dylib

fi

# remove docs
rm -rf $PREFIX/suitesparse_docs
