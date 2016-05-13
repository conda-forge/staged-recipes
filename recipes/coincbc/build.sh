#!/usr/bin/env bash
set -e

UNAME="$(uname)"
export CFLAGS="-O3"
export CXXFLAGS="-O3"
if [ "${UNAME}" == "Darwin" ]; then
  # for Mac OSX
  export CC=gcc
  export CXX=g++

  # Coin options
  WITH_BLAS_LIB="-L${PREFIX}/lib -lopenblas"
  WITH_LAPACK_LIB="-L${PREFIX}/lib -lopenblas"
else
  # for Linux
  export CC=
  export CXX=
  WITH_BLAS_LIB="-L${PREFIX}/lib -lopenblas"
  WITH_LAPACK_LIB="-L${PREFIX}/lib -lopenblas"
fi

CC="${CC}" CXX="${CXX}" ./configure --prefix="${PREFIX}" --exec-prefix="${PREFIX}" \
  --with-blas-lib="${WITH_BLAS_LIB}" \
  --with-lapack-lib="${WITH_LAPACK_LIB}" \
  || { cat config.log; exit 1; }
make
if [ "${UNAME}" == "Linux" ]; then
  make test
fi
make install
