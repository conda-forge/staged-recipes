#!/usr/bin/env bash

# set all env vars
export FOAM_SOLVERS=${CONDA_PREFIX}/include/OpenFOAM-${PKG_VERSION}/applications/solvers
export FOAM_APPBIN=${CONDA_PREFIX}/bin
export FOAM_SITE_APPBIN=${CONDA_PREFIX}/bin
export FOAM_APP=${CONDA_PREFIX}/include/OpenFOAM-${PKG_VERSION}/applications
export FOAM_SITE_LIBBIN=${CONDA_PREFIX}/lib
export FOAM_SRC=${CONDA_PREFIX}/include/OpenFOAM-${PKG_VERSION}/src
export FOAM_UTILITIES=${CONDA_PREFIX}/include/OpenFOAM-${PKG_VERSION}/applications/utilities
export FOAM_API=2212
export FOAM_USER_LIBBIN=${CONDA_PREFIX}/lib
export FOAM_ETC=${CONDA_PREFIX}/include/OpenFOAM-${PKG_VERSION}/etc
export FOAM_MPI=sys-openmpi
export FOAM_LIBBIN=${CONDA_PREFIX}/lib
export FOAM_USER_APPBIN=${CONDA_PREFIX}/bin

export WM_ARCH=linux64
export WM_COMPILER_TYPE=system
export WM_PROJECT_VERSION=${PKG_VERSION}
export WM_COMPILER_LIB_ARCH=64
export WM_PROJECT_DIR="${CONDA_PREFIX}/include/OpenFOAM-${PKG_VERSION}"
export WM_LABEL_OPTION=Int32
export WM_PROJECT=OpenFOAM
export WM_COMPILER=Gcc
export WM_MPLIB=SYSTEMOPENMPI
export WM_COMPILE_OPTION=Opt
export WM_DIR="${CONDA_PREFIX}/include/OpenFOAM-${PKG_VERSION}/wmake"
export WM_LABEL_SIZE=32
export WM_OPTIONS=linux64GccDPInt32Opt
export WM_PRECISION_OPTION=DP