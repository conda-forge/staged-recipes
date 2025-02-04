#!/bin/bash
set -e  # Exit on first error

# Create necessary directories
mkdir -p build_core install_core
cd build_core
export ISISROOT=$PWD

# Ensure Conda's Python and libraries are used
export CMAKE_PREFIX_PATH=$CONDA_PREFIX
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH

# Debugging: Check if libpython exists
ls -l $CONDA_PREFIX/lib | grep python

# Run CMake with explicit Python paths
cmake -GNinja \
  -DBUILD_TESTS=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DISIS_BUILD_SWIG=ON \
  -DCMAKE_INSTALL_PREFIX=../install_core \
  -DPython3_ROOT_DIR=$CONDA_PREFIX \
  -DPython3_EXECUTABLE=$CONDA_PREFIX/bin/python \
  -DPython3_LIBRARY=$CONDA_PREFIX/lib/libpython3.12m.so \
  ../isis/src/core

# Build and install
ninja && ninja install

# Install Python bindings
cd swig/python
$CONDA_PREFIX/bin/python setup.py install
