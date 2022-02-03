#!/bin/bash
set -ex

mkdir build
cd build

cmake ..  -DCMAKE_INSTALL_PREFIX=${PREFIX}

cmake --build . --target install

make check MPIEXEC="mpirun -np 2"