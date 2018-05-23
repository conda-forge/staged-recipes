#!/usr/bin/env bash
mkdir build
cd build

# export CC=gcc-4.9
# export CXX=g++-4.9

cmake .. -G "Ninja" \
    -DCMAKE_BUILD_TYPE="Release" \
    -DPTHREAD_INCLUDE_DIRS=$PREFIX \
    -DENABLE_SMESH=ON \
    -DENABLE_NETGEN=ON

ninja install

cd ..
python setup.py install
