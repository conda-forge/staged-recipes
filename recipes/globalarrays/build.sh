#!/bin/bash
set -ex

mkdir build
cd build

export MPIEXEC_MAX_NUMPROCS=2

cmake .. \
 -DCMAKE_INSTALL_PREFIX=${PREFIX} \
 -DENABLE_TESTS=ON

cmake --build . --target install