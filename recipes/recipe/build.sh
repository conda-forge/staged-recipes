#!/bin/bash
set -ex

mkdir build
cd build

cmake .. \

#    -DLINALG=OpenBLAS \

make

pymolcas verify
