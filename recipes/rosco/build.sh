#!/bin/bash

mkdir build
cd build

cmake .. -D CMAKE_Fortran_FLAGS="-ffree-line-length-0"
make