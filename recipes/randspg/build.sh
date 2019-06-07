#!/bin/bash 
mkdir build
cd build 
cmake .. 
make -j3 
cp randSpg $PREFIX/bin/randSpg
