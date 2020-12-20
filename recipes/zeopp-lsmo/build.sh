#!/bin/bash

mkdir -p ${PREFIX}/bin

cd voro++
make
cp src/voro++ ${PREFIX}/bin/
cd ../

cd zeo++
CFLAGS="$CFLAGS -I$PREFIX/include/eigen3" make
cp network ${PREFIX}/bin/
cd ../
