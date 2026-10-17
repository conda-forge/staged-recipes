#!/bin/bash
set -ex

# PETSc from the conda environment
export PETSC_DIR=$PREFIX
export PETSC_ARCH=""

# Build PFLARE and the Python bindings
# CONDA_BUILD=1 tells the PFLARE makefile to only link the libraries it uses to avoid overlinking
make -j"${CPU_COUNT}" CONDA_BUILD="1"
make -j"${CPU_COUNT}" python CONDA_BUILD="1"

# Quick sanity check of the build (serial and parallel), can't run when cross-compiling
if [[ "${CONDA_BUILD_CROSS_COMPILATION:-0}" != "1" ]]; then
  # Fix mpich gethostbyname() issues in Azure Pipelines (as in the slepc feedstock)
  if [[ $(uname) == Darwin ]]; then
    export HYDRA_IFACE=lo0
  fi
  make check CONDA_BUILD="1"
fi

# Install the library, headers, Fortran modules and Python bindings
make install CONDA_BUILD="1" PREFIX="$PREFIX" PYVER="$PY_VER"
