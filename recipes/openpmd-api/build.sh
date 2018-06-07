#!/bin/bash

mkdir build
cd build

cmake \
    -DCMAKE_BUILD_TYPE=Release  \
    -DopenPMD_USE_MPI=OFF       \
    -DopenPMD_USE_HDF5=ON       \
    -DopenPMD_USE_ADIOS1=ON     \
    -DopenPMD_USE_ADIOS2=OFF    \
    -DopenPMD_USE_PYTHON=ON     \
    -DPYTHON_EXECUTABLE:FILEPATH=$(which $PYTHON)  \
    -DBUILD_TESTING=ON              \
    -DCMAKE_INSTALL_LIBDIR=lib      \
    -DCMAKE_INSTALL_PREFIX=$PREFIX  \
    $SRC_DIR

make
make test
make install
