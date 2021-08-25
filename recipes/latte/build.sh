#!/bin/bash 
mkdir build 
cd build
cmake ../cmake
make
cp liblatte.a ${PREFIX}/lib
