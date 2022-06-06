#!/bin/bash

set -x -e
set -o pipefail

cd python
mkdir -p build/release
cd build/release
cmake -G "Unix Makefiles" \
  -DCMAKE_BUILD_TYPE=Release \
  -DPython3_EXECUTABLE="$PYTHON" \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DRIVER_INSTALL=ON \
  ${CMAKE_ARGS} \
  ../..
make
make install

