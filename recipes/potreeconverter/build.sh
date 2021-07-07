#!/bin/bash
set -eox pipefail

PREFIX=$(echo "${PREFIX}" | tr '\\' '/')

# Remove later
# Apparently task was deprecated in 2021, so need to use tbb=2020
conda install -y mamba
mamba install -y tbb-devel=2020 cmake make cxx-compiler laszip
RECIPE_DIR=/data

# Copy library files with correct versioning to tbb-devel
ln -s $CONDA_PREFIX/pkgs/tbb-2*/lib/* $CONDA_PREFIX/pkgs/tbb-devel-2*/lib/

# Copy tbb files so make compiling can see them
cd /opt/conda/x86_64-conda-linux-gnu/include/c++/*
mkdir tbb oneapi
ln -s $CONDA_PREFIX/pkgs/tbb-devel-20*/include/tbb/* /opt/conda/x86_64-conda-linux-gnu/include/c++/*/tbb
ln -s $CONDA_PREFIX/pkgs/tbb-devel-20*/include/oneapi/* /opt/conda/x86_64-conda-linux-gnu/include/c++/*/oneapi
cd /usr/lib/
mkdir tbb oneapi
ln -s $CONDA_PREFIX/pkgs/tbb-devel-20*/include/tbb/* /opt/conda/x86_64-conda-linux-gnu/include/c++/*/tbb
ln -s $CONDA_PREFIX/pkgs/tbb-devel-20*/include/oneapi/* /opt/conda/x86_64-conda-linux-gnu/include/c++/*/oneapi


mkdir $RECIPE_DIR/build/
cd $RECIPE_DIR/build/
cmake \
    -DCMAKE_INSTALL_PREFIX=$CONDA_PREFIX \
    -DCMAKE_PREFIX_PATH=$CONDA_PREFIX/pkgs \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DBUILD_SHARED_LIBS=1 \
    -DTBB_FOUND=1 \
    ../
make

