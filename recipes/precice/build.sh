#!/bin/bash
mkdir build
cd build
cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make -j${NUM_CPUS}
