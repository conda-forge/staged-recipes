#!/bin/bash
sed -i "s|LAPACK=-llapack|LAPACK=-L $PREFIX/lib -llapack|g" src/Makefile.g95
cd src
make -f Makefile.g95
cp atomsk $PREFIX/bin/atomsk
