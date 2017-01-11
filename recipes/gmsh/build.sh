#!/bin/sh
# see http://conda.pydata.org/docs/build.html for hacking instructions.

# unpack.
mkdir build
cd build

# build.
cmake \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DENABLE_OS_SPECIFIC_INSTALL=OFF \
    -DENABLE_MATCH=OFF \
    -DENABLE_PETSC=OFF \
    -DENABLE_SLEPC=OFF \
    .. | tee cmake.log 2>&1
#     -DBLAS_LAPACK_LIBRARIES=${PREFIX}/lib/libopenblas${SHLIB_EXT} \

make | tee make.log 2>&1
make install | tee install.log 2>&1

# vim: set ai et nu:
