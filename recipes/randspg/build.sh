#!/bin/bash 
mkdir build
cd build 
cmake .. 
make -j3 
mkdir -p $PREFIX/bin
cp randSpg $PREFIX/bin/randSpg
