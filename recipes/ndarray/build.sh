#!/bin/bash

export BOOST_DIR=$PREFIX
export EIGEN_DIR=$PREFIX
export FFTW_DIR=$PREFIX
export CMAKE_PREFIX_PATH=$PREFIX


mkdir build
cd build
cmake -DNDARRAY_PYBIND11=ON -DCMAKE_INSTALL_PREFIX=$PREFIX ..
make
make test ARGS="-V"

make install
