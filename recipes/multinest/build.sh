#!/bin/bash

set -e

cd build
cmake \
    -DCMAKE_INSTALL_PREFIX=${PREFIX} \
    -DCMAKE_PREFIX_PATH=${PREFIX} \
    -DMULTINEST_USE_MPI \
    ..
make
make install
