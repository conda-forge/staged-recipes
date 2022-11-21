#!/bin/bash

cd Examples/ColPackAll
make
./ColPack -f ../../Graphs/bcsstk01.mtx -m DISTANCE_ONE -o LARGEST_FIRST RANDOM -v
./ColPack -f ../../Graphs/bcsstk01.mtx -m PD2_OMP_GMMP -o RANDOM -v