#!/usr/bin/env bash
set -e

UNAME="$(uname)"
export CFLAGS="${CFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS} -O3"
export CXXFLAGS="${CXXFLAGS//-std=c++17/-std=c++11}"

if [ "${UNAME}" == "Linux" ]; then
    export FLIBS="-lgcc_s -lgcc -lstdc++ -lm"
fi

# Use only 1 thread with OpenBLAS to avoid timeouts on CIs.
# This should have no other affect on the build. A user
# should still be able to set this (or not) to a different
# value at run-time to get the expected amount of parallelism.
export OPENBLAS_NUM_THREADS=1

WITH_BLAS_LIB="-L${PREFIX}/lib -lblas"
WITH_LAPACK_LIB="-L${PREFIX}/lib -llapack"

./configure \
    --prefix="${PREFIX}" \
    --exec-prefix="${PREFIX}" \
    --with-blas-lib="${WITH_BLAS_LIB}" \
    --with-lapack-lib="${WITH_LAPACK_LIB}" \
    --enable-gnu-packages

make -j "${CPU_COUNT}"
# if [ "${UNAME}" == "Linux" ]; then
#   make test
# fi
make install