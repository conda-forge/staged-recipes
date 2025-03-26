#!/usr/bin/env bash

# set all env vars
export FOAM_API=2412

export WM_PROJECT_DIR="${CONDA_PREFIX}"
export WM_ARCH=linux64
export WM_COMPILER_TYPE=system
export WM_PROJECT_VERSION=v${FOAM_API}
export WM_COMPILER_LIB_ARCH=64

export WM_LABEL_OPTION=Int32
export WM_PROJECT=OpenFOAM
export WM_COMPILER=Gcc
export WM_MPLIB=MPICH
export WM_COMPILE_OPTION=Opt
export WM_DIR=${WM_PROJECT_DIR}/wmake
export WM_LABEL_SIZE=32
export WM_OPTIONS=linux64GccDPInt32Opt
export WM_PRECISION_OPTION=DP

export FOAM_SOLVERS=${WM_PROJECT_DIR}/applications/solvers
export FOAM_APPBIN=${CONDA_PREFIX}/bin
export FOAM_SITE_APPBIN=${CONDA_PREFIX}/bin
export FOAM_APP=${WM_PROJECT_DIR}/applications
export FOAM_SITE_LIBBIN=${CONDA_PREFIX}/lib
export FOAM_SRC=${WM_PROJECT_DIR}/src
export FOAM_UTILITIES=${FOAM_APP}/utilities
export FOAM_USER_LIBBIN=${CONDA_PREFIX}/lib
export FOAM_ETC=${WM_PROJECT_DIR}/etc
export FOAM_MPI=sys-mpich
export FOAM_LIBBIN=${CONDA_PREFIX}/lib
export FOAM_USER_APPBIN=${CONDA_PREFIX}/bin

