#!/bin/bash

# Avoid errors on the server such as:
#  - Error: virtual memory exhausted: Cannot allocate memory
#  - Error: Exit code 137
# due to many parallel jobs consuming all available memory
JOBS=$((CPU_COUNT*2 - 1))

echo "Using $JOBS parallel jobs out of $((CPU_COUNT*2)) available to build Optima."

# Configure the build of Optima
cmake -S . -B build ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_VERBOSE_MAKEFILE=ON \
    -DPYTHON_EXECUTABLE=$PYTHON

# Build and install Optima in $PREFIX
cmake --build build --target install --parallel $JOBS
