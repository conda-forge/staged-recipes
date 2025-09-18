#!/bin/bash
set -ex

# PETSc from conda environment
export PETSC_DIR=$PREFIX
export PETSC_ARCH=""

# Define the path to the PETSc source headers extracted by conda-build.
# This assumes you have `folder: petsc_src` in your meta.yaml for the PETSc source.
PETSC_SRC_INCLUDE_DIR="$SRC_DIR/petsc_src/include"

# Add the explicit source include path to the compiler flags.
# We need some of the petsc private headers that aren't included in builds
export CFLAGS="-I${PETSC_SRC_INCLUDE_DIR} ${CFLAGS}"
export CXXFLAGS="-I${PETSC_SRC_INCLUDE_DIR} ${CXXFLAGS}"
export CPPFLAGS="-I${PETSC_SRC_INCLUDE_DIR} ${CPPFLAGS}"

# PFLARE source directory given the source in the yaml
cd $SRC_DIR/pflare_src

# Build PFLARE and Python bindings
# Have to explicitly tell make that this is a conda build to avoid overlinking
make -j${CPU_COUNT} "CONDA_BUILD=1"
make -j${CPU_COUNT} python "CONDA_BUILD=1"
# Check the build
make -j${CPU_COUNT} check "CONDA_BUILD=1"

# --- Manual Installation ---

# 1. Create the destination directories
# The library will go in $PREFIX/lib
mkdir -p $PREFIX/lib
# The Python modules will go in the site-packages directory
SITE_PACKAGES_DIR=$PREFIX/lib/python${PY_VER}/site-packages
mkdir -p $SITE_PACKAGES_DIR

# 2. Copy the library
# Assumes the library is named libpflare* and is in the top-level build directory
cp lib/libpflare* $PREFIX/lib/

# 3. Copy the Python modules
# The python files are in the 'python' subdirectory. The `*` glob handles
# the full name of the compiled Cython module (e.g., pflare_defs.cpython-311-x86_64-linux-gnu.so)
cp python/pflare.py $SITE_PACKAGES_DIR/
cp python/pflare_defs.cpython-*.so $SITE_PACKAGES_DIR/