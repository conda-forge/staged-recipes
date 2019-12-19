#!/bin/bash

set -u
ferr(){
    echo "$@"
    exit 1
}

CXX_STANDARD=${CXX_STANDARD:-14}
echo "requesting c++ standard ${CXX_STANDARD}"
BUILD_TYPE=${BUILD_TYPE:-Release}

mkdir build
cd build
python_path=$(which python)
# Configure step
cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DEnableSSE=OFF \
      -DBuildTests=OFF \
      -DBuildVelocyPackExamples=OFF \
      -DBuildLargeTests=OFF \
      -DCMAKE_CXX_STANDARD=${CXX_STANDARD} \
      ..
# Build step
make -j${CPU_COUNT}
make install
