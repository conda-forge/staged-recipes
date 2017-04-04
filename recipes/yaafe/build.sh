#!/bin/bash

mkdir build_yaafe
cd build_yaafe
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DWITH_FFTW3=ON -DWITH_HDF5=ON -DWITH_LAPACK=ON -DWITH_MPG123=ON -DWITH_EIGEN_LIBRARY=ON ..
make
make install
