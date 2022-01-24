#!/bin/bash

set -ex

mkdir build
cd build

# The order we do this matters - the C++ library has to be linked to the conda version of laz-perf
# and the python library has to be statically linked to laz-perf
# so, build the c++ library first, then clone lazperf and build python library
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
