#!/bin/bash

mkdir build
cd build
cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DPython_FIND_FRAMEWORK=NEVER \
    -DPython_FIND_STRATEGY=LOCATION \
    ..
cmake --build .
cmake --build . --target test
rm -r /tmp/hdf5
cmake --build . --target install
