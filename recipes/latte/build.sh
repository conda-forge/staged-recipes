#!/bin/bash 
mkdir build 
cd build
cmake ../cmake
make
mkdir ${PREFIX}/lib
cp liblatte.a ${PREFIX}/lib
