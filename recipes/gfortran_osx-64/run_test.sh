#!/bin/bash

gfortran -o hello hello.f90 -Wl,-rpath,${PREFIX}/lib
./hello
rm -f hello

gfortran -O3 -fopenmp -ffast-math -o maths maths.f90 -Wl,-rpath,${PREFIX}/lib
./maths
rm -f maths
