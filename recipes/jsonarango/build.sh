#!/bin/bash

set -u
ferr(){
    echo "$@"
    exit 1
}

mkdir -p build
cd build

# Configure step
cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX="$PREFIX" \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DJSONARANGO_BUILD_EXAMPLES=OFF \
      ..
# Build step
make -j${CPU_COUNT}
make install
