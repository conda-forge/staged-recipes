#!/bin/bash
set -ex

mkdir build
cd build

cmake .. \
    -DLINALG=OpenBLAS \
    -DOPENBLASROOT=$PREFIX \

make

pymolcas verify
