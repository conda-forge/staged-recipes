#!/bin/bash
set -e  # Exit on first error

# Create necessary directories
mkdir -p build_core install_core
cd build_core
export ISISROOT=$PWD

# Ensure Conda's Python and libraries are used
export CMAKE_PREFIX_PATH=$CONDA_PREFIX
export LD_LIBRARY_PATH=$CONDA_PREFIX/lib:$LD_LIBRARY_PATH

# Run CMake with explicit Python paths
cmake -GNinja \
  -DBUILD_TESTS=OFF \
  -DCMAKE_BUILD_TYPE=Release \
  -DISIS_BUILD_SWIG=ON \
  -DCMAKE_INSTALL_PREFIX=../install_core \
  -DPython3_EXECUTABLE=$PYTHON \
  -DPython3_LIBRARY=$PREFIX/lib/libpython${PY_VER}m.so \
  -DPython3_INCLUDE_DIR=$PREFIX/include/python${PY_VER} \
  ../isis/src/core

# Build and install
ninja && ninja install

# Install Python bindings
cd swig/python
$PYTHON setup.py install
