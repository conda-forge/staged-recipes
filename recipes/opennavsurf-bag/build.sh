#!/bin/bash

set -ex # Abort on error.

mkdir build

# Configure CMake build
cmake -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -B build -S . \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DBUILD_SHARED_LIBS:BOOL=ON \
  -DBAG_BUILD_TESTS:BOOL=OFF \
  -DBAG_BUILD_PYTHON:BOOL=OFF

# Build C++
cmake --build build -j ${CPU_COUNT} --config Release

# Build Python wheel
$PYTHON -m pip wheel -w ./wheel ./build/api/swig/python

# Install it
cmake --install build
$PYTHON -m pip install ./wheel/bagPy-*.whl

# Test it
BAG_SAMPLES_PATH=./examples/sample-data ./build/tests/bag_tests
BAG_SAMPLES_PATH=./examples/sample-data $PYTHON -m pytest python/test_*.py
