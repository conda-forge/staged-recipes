#!/usr/bin/env bash

# tar zxf wgms3d-2.0.tar.gz ; cd wgms3d-2.0


# set -e
# if test "$(uname)" = "Darwin"
# then
#   SO_EXT='.dylib'
# else
#   SO_EXT='.so'
# fi

# LIB="${PREFIX}/lib"
# BIN="${PREFIX}/bin"
# RPATH_FLAGS="-Wl,-rpath,${LIB}"
# MY_LDFLAGS="-L${LIB} ${RPATH_FLAGS}"
# MY_CPPFLAGS="-I${PREFIX}/include"
# BLAS="${LIB}/libopenblas${SO_EXT}"
# CC="${BIN}/gcc"
# CPP="${BIN}/g++"
# FOR="${BIN}/gfortran"

# ./configure --prefix="${PREFIX}" F77="${FOR}" CC="${CC}" CXX="${CPP}" LDFLAGS="${MY_LDFLAGS}" CPPFLAGS="${MY_CPPFLAGS}" --with-blas="${BLAS}"
# ./configure --prefix=${PREFIX}  --with-arpack --with-superlu
./configure  --with-arpack --with-superlu
make
make install
