#!/bin/bash

$FC -o hello hello.f90 -Wl,-rpath,${PREFIX}/lib
./hello
rm -f hello

$Fc -O3 -fopenmp -ffast-math -o maths maths.f90 -Wl,-rpath,${PREFIX}/lib
./maths
rm -f maths

if [[ ! $FFLAGS ]]
then
    exit 1
fi
