#!/bin/bash
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${PREFIX} ..
make -j${NUM_CPUS}
make test
make install
