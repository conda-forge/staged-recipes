#!/bin/bash

set -x
set -e

mkdir build
cd build

cmake \
  -GNinja \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_TESTING=OFF -DBUILD_EXAMPLES=OFF \
  -DWITH_DCMTK=OFF \
  -DBUILD_PYTHON_WRAPPERS=ON -DBUILD_JAVASCRIPT_WRAPPERS=OFF \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} -DPYTHON_EXECUTABLE=${PYTHON} \
  ../

cmake --build . --target install
