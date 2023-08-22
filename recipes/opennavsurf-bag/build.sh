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
  -DBAG_BUILD_TESTS:BOOL=ON \
  -DBAG_BUILD_PYTHON:BOOL=ON

# Build it
cmake --build build -j ${CPU_COUNT} --config Release

# Install it
cmake --install build
python ./build/api/swig/python/setup.py install

# Test it
BAG_SAMPLES_PATH=./examples/sample-data ./build/tests/bag_tests
pytest --cov=bagPy --cov-branch --cov-report=xml --junitxml=python-test-results.xml python/test_*.py
