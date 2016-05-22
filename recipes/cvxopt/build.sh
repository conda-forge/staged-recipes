#!/bin/bash


if [ "$(uname)" == "Linux" ];
then
    # SuiteSparse needs the Real Time library on Linux.
    export CFLAGS="${CFLAGS} -lrt"
fi

export CVXOPT_BLAS_LIB_DIR="${PREFIX}/lib"
export CVXOPT_BLAS_LIB="openblas"
export CVXOPT_LAPACK_LIB="openblas"

export CVXOPT_BUILD_GSL=1
export CVXOPT_GSL_LIB_DIR="${PREFIX}/lib"
export CVXOPT_GSL_INC_DIR="${PREFIX}/include"

export CVXOPT_BUILD_FFTW=1
export CVXOPT_FFTW_LIB_DIR="${PREFIX}/lib"
export CVXOPT_FFTW_INC_DIR="${PREFIX}/include"

export CVXOPT_BUILD_GLPK=1
export CVXOPT_GLPK_LIB_DIR="${PREFIX}/lib"
export CVXOPT_GLPK_INC_DIR="${PREFIX}/include"

#
# Once we build SuiteSparse, we can revisit this.
#
#export CVXOPT_SUITESPARSE_EXT_LIB=1
#export CVXOPT_AMD_EXT_LIB="${PREFIX}/lib"
#export CVXOPT_AMD_EXT_LIB="${PREFIX}/include"

$PYTHON setup.py install --single-version-externally-managed --record=record.txt
