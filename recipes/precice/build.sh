#!/bin/bash
mkdir build
cd build
export NumPy_INCLUDE_DIR=$(python -c "import numpy; print(numpy.get_include())")
cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=${PREFIX} -DNumPy_INCLUDE_DIR=${NumPy_INCLUDE_DIR} ..
make
