#!/bin/bash

cd Examples/Use_Library
$CXX $CXXFLAGS $LDFLAGS -lColPack -fopenmp template.cpp -o ColPack
./ColPack -f ../../Graphs/bcsstk01.mtx -m DISTANCE_ONE -o LARGEST_FIRST RANDOM -v
./ColPack -f ../../Graphs/bcsstk01.mtx -m PD2_OMP_GMMP -o RANDOM -v