#!/bin/bash

# Avoid errors on the server such as:
#  - Error: virtual memory exhausted: Cannot allocate memory
#  - Error: Exit code 137
# due to many parallel jobs consuming all available memory
JOBS=$((CPU_COUNT*2 - 1))

echo "Using $JOBS parallel jobs out of $((CPU_COUNT*2)) available to build eigen4rkt."

# Configure the build of eigen4rkt
cmake -S . -B build ${CMAKE_ARGS} \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_BUILD_TYPE=Release

# Build eigen4rkt in $PREFIX (and install eigen via ExternalProject_Add (no need for --target install))
cmake --build build --parallel $JOBS
