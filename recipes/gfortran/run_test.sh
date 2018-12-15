#!/bin/bash

# we need to tell the linker where to look in our tests
# this step is not needed when using conda build
export DYLD_FALLBACK_LIBRARY_PATH=${PREFIX}/lib

gfortran -o hello hello.f90
./hello
rm -f hello

gfortran -O3 -fopenmp -ffast-math -o maths maths.f90
./maths
rm -f maths
