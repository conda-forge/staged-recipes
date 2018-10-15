#!/bin/bash

set -e
gfortran -o hello hello.f90
./hello
rm -f hello

gfortran -O3 -fopenmp -ffast-math -o maths maths.f90
./maths
rm -f maths
