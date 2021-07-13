#!/bin/bash
cd src/
make F90=gfortran
cp libutils.a ${PREFIX}/lib
cp libsym.a ${PREFIX}/lib
cp libcomparestructs.a ${PREFIX}/lib
cp librational.a ${PREFIX}/lib
cp libcombinatorics.a ${PREFIX}/lib
