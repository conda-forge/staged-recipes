#!/usr/bin/env bash

mkdir build
cd build

export CXXFLAGS="$CXXFLAGS -D_LIBCPP_DISABLE_AVAILABILITY"
source $PREFIX/share/triqs/triqsvars.sh

cmake ${CMAKE_ARGS} \
    -DCMAKE_CXX_COMPILER=${BUILD_PREFIX}/bin/$(basename ${CXX}) \
    -DCMAKE_C_COMPILER=${BUILD_PREFIX}/bin/$(basename ${CC}) \
    -DCMAKE_Fortran_COMPILER=${BUILD_PREFIX}/bin/$(basename ${FC}) \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_BUILD_TYPE=Release \
    -DBuild_Deps=IfNotFound \
    ..

make -j1 VERBOSE=1
CTEST_OUTPUT_ON_FAILURE=1 ctest
make install
