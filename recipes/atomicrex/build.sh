#!/bin/bash
mkdir build
cd build
cmake -DPYTHON_INCLUDE_DIR=${PREFIX}/bin/python -DPYTHON_LIBRARY=${PREFIX}/lib/libpython*.so -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make
make install
