#!/bin/bash

rm -rf build
mkdir build
cd build

export LIBRARY_PATH=$PREFIX/lib
export INCLUDE_PATH=$PREFIX/include

export PETSC_DIR=$PREFIX
export SLEPC_DIR=$PREFIX
export CMAKE_PREFIX_PATH=$PREFIX

cmake .. \
      -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_INCLUDE_PATH=$INCLUDE_PATH \
      -DCMAKE_LIBRARY_PATH=$LIBRARY_PATH \
      -DPYTHON_EXECUTABLE=$PYTHON || (cat CMakeFiles/CMakeError.log && exit 1)

make VERBOSE=1 -j${CPU_COUNT}
make install
