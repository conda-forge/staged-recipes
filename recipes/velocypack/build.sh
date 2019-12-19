#!/bin/bash
mkdir build
cd build
python_path=$(which python)
# Configure step
cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX="$PREFIX" \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DHashType=xxhash \
      -DBuildTests=ON \
      -DBuildVelocyPackExamples=ON \
      -DBuildLargeTests=OFF \
      ..
# Build step
make -j${CPU_COUNT}
make install
