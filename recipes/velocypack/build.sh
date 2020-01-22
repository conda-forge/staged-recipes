#!/bin/bash

set -u
ferr(){
    echo "$@"
    exit 1
}

CXX_STANDARD=${CXX_STANDARD:-14}
echo "requesting c++ standard ${CXX_STANDARD}"

mkdir -p build
cd build

# Configure step
cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX="$PREFIX" \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
      -DEnableSSE=OFF \
      -DBuildTests=OFF \
      -DBuildVelocyPackExamples=OFF \
      -DBuildTools=ON \
      -DBuildLargeTests=OFF \
      -DCMAKE_CXX_STANDARD=${CXX_STANDARD} \
      ..
# Build step
make -j${CPU_COUNT}
make install
