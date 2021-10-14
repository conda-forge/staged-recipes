#!/bin/bash


export KVXOPT_BLAS_LIB_DIR="${PREFIX}/lib"
export KVXOPT_BLAS_LIB="blas"
export KVXOPT_LAPACK_LIB="lapack"

export KVXOPT_BUILD_GSL=1
export KVXOPT_GSL_LIB_DIR="${PREFIX}/lib"
export KVXOPT_GSL_INC_DIR="${PREFIX}/include"

export KVXOPT_BUILD_FFTW=1
export KVXOPT_FFTW_LIB_DIR="${PREFIX}/lib"
export KVXOPT_FFTW_INC_DIR="${PREFIX}/include"

export KVXOPT_BUILD_GLPK=1
export KVXOPT_GLPK_LIB_DIR="${PREFIX}/lib"
export KVXOPT_GLPK_INC_DIR="${PREFIX}/include"

export KVXOPT_BUILD_DSDP=1
export KVXOPT_DSDP_LIB_DIR="${PREFIX}/lib"
export KVXOPT_DSDP_INC_DIR="${PREFIX}/include"

export KVXOPT_BUILD_OSQP=1
export KVXOPT_OSQP_LIB_DIR="${PREFIX}/lib"
export KVXOPT_OSQP_INC_DIR="${PREFIX}/include/osqp"

export KVXOPT_SUITESPARSE_LIB_DIR="${PREFIX}/lib"
export KVXOPT_SUITESPARSE_INC_DIR="${PREFIX}/include"

$PYTHON setup.py install --single-version-externally-managed --record=record.txt

cp src/C/cvxopt.h ${PREFIX}/include