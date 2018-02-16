#!/bin/sh
# see http://conda.pydata.org/docs/build.html for hacking instructions.

# unpack.
mkdir build
cd build

# build.
cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_MODULE_Draw=0 \
    -DBUILD_MODULE_Visualization=0 \
    -DBUILD_MODULE_ApplicationFramework=0 \
    .. | tee cmake.log 2>&1

make | tee make.log 2>&1
make install | tee install.log 2>&1

# vim: set ai et nu:
