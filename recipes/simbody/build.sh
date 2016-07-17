#!/bin/bash
source activate "${CONDA_DEFAULT_ENV}"
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX="$PREFIX" -DBUILD_VISUALIZER=off
make
ctest -R TestMassMatrix
make install
