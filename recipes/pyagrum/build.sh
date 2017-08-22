#!/bin/sh

mkdir build && cd build
cmake \
  -DCMAKE_PREFIX_PATH=${PREFIX} \
  -DCMAKE_INSTALL_PREFIX=${PREFIX} \
  -DFOR_PYTHON3=${PY3K} \
  ..
make install -j${CPU_COUNT}
${PYTHON} ../wrappers/pyAgrum/testunits/TestSuite.py
