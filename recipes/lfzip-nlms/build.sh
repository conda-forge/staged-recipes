#!/bin/bash

mkdir -p $PREFIX/bin
cd src/
$CXX nlms_helper.cpp -std=c++11 -Wall -O3 $CFLAGS -o nlms_helper.out $LDFLAGS
cp nlms_helper.out $PREFIX/bin
cp nlms_compress.py $PREFIX/bin/lfzip-nlms
