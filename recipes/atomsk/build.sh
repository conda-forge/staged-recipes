#!/bin/bash
export LAPACK=$PREFIX/lib/liblapack.so
make atomsk
cp atomsk $PREFIX/bin/atomsk
