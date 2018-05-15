#!/bin/bash
cd 3.0/src
cp $RECIPE_DIR/make.inc ./make.inc

make all

cd ../

mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/include

cp lib/x64/*.a ${PREFIX}/lib
cp include/*.h ${PREFIX}/include
