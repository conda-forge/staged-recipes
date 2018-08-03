#!/bin/sh

mkdir build && cd build

cmake \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DPython_ADDITIONAL_VERSIONS=3 \
  ..

cd cython
$PYTHON setup.py install

