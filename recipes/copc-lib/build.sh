#!/bin/bash

set -ex
export CMAKE_GENERATOR=Ninja

mkdir build
cd build

cmake -G "Ninja" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DWITH_TESTS=OFF \
  -DWITH_PYTHON=OFF \
  ..

cmake --build .
cmake --install .

cd $SRC_DIR

#git clone --depth 1 --branch 3.0.0 https://github.com/hobu/laz-perf.git libs/laz-perf
$PYTHON setup.py install
