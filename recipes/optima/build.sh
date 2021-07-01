#!/bin/bash

# Avoid errors on the server such as:
#  - Error: virtual memory exhausted: Cannot allocate memory
#  - Error: Exit code 137
# due to many parallel jobs consuming all available memory
JOBS=$((CPU_COUNT - 1))

echo "Using $JOBS parallel jobs out of $CPU_COUNT available to build Optima and its dependencies."

# Configure the build of Optima
cmake -S . -B build \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DPYTHON_EXECUTABLE=$PYTHON

# Build and install Optima in $PREFIX
cmake --build build --target install --parallel $JOBS
