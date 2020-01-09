#!/usr/bin/env bash
mkdir build
cd build

# export CC=gcc-4.9
# export CXX=g++-4.9

cmake .. -G "Ninja" \
    -DCMAKE_BUILD_TYPE="Release" \
    -DENABLE_SMESH=OFF \
    -DENABLE_NETGEN=OFF \
    -DENABLE_FORCE=OFF

ninja install

cd ..
${PYTHON} setup.py install
