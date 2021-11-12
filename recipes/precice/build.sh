#!/bin/bash
mkdir build
cd build
export NumPy_INCLUDE_DIR=${PREFIX}/include
cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make -j${NUM_CPUS}
