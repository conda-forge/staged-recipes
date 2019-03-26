#!/bin/bash

mkdir -p build
cd build

cmake \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DDISABLE_OPENMP=1 \
  -DVISUS_GUI=0 \
  -DVISUS_INTERNAL_DEFAULT=1 \
  -DPYTHON_VERSION=$PY_VER \
  -DPYTHON_EXECUTABLE=$PYTHON \
  ..
  
cmake --build . --target all -- -j ${CPU_COUNT}
cmake --build . --target install

cd install
$PYTHON setup.py install --single-version-externally-managed --record=record.txt

