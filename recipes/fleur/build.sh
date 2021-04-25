#!/bin/bash

FC=mpif90 ./configure.sh AUTO

make

mkdir -p ${PREFIX}/bin
cp build/fleur_MPI ${PREFIX}/bin
cp build/inpgen ${PREFIX}/bin
