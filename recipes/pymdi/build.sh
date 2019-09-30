#!/bin/bash
mkdir build
cd build
# Configure step
cmake -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -Dpython_package=ON \
    -Dlanguage=Python \
    ..
# Build step
make -j${CPU_COUNT}
make install
