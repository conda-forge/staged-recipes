#!/bin/sh

C=$CXX make

$CXX -shared -o libhmm${SHLIB_EXT} build/release/*.o
mkdir -p $PREFIX/lib
cp libhmm${SHLIB_EXT} $PREFIX/lib

mkdir -p $PREFIX/include/hmm
cp -r src/*.h $PREFIX/include/hmm
mkdir -p $PREFIX/bin
cp bin/release/hmm $PREFIX/bin
