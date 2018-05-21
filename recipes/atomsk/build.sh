#!/bin/bash
export LAPACK=$PREFIX/lib/liblapack.so
cd src
make atomsk
cp atomsk $PREFIX/bin/atomsk
