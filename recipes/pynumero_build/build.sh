#!/bin/bash -e

mkdir build
cd build

cmake .. -DMP_PATH=$PREFIX -DCMAKE_BUILD_TYPE=Release

make 

cp asl_interface/libpynumero_* $PREFIX/lib
cp sparse_utils/libpynumero_* $PREFIX/lib
cp tests/asl_test $PREFIX/bin
