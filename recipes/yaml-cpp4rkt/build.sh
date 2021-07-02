#!/bin/bash

# Avoid errors on the server such as:
#  - Error: virtual memory exhausted: Cannot allocate memory
#  - Error: Exit code 137
# due to many parallel jobs consuming all available memory
JOBS=$((CPU_COUNT*2 - 1))

echo "Using $JOBS parallel jobs out of $((CPU_COUNT*2)) available to build yaml-cpp4rkt."

# Configure the build of yaml-cpp4rkt
cmake -S . -B build ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DBUILD_SHARED_LIBS=ON \
    -DYAML_BUILD_SHARED_LIBS=ON \
    -DYAML_CPP_BUILD_TESTS=OFF

# Build and install yaml-cpp4rkt in $PREFIX
cmake --build build --target install --parallel $JOBS
