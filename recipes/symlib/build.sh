#!/bin/bash
cd src/
export FFLAGS=${FFLAGS}" -ffree-line-length-none"
make
cp libutils.a ${PREFIX}/lib
cp libsym.a ${PREFIX}/lib
cp libcomparestructs.a ${PREFIX}/lib
cp librational.a ${PREFIX}/lib
cp libcombinatorics.a ${PREFIX}/lib
