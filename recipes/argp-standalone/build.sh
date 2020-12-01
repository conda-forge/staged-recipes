#!/bin/bash

mkdir -p ${PREFIX}/lib ${PREFIX}/include
./configure --prefix=${PREFIX}
make
cp libargp.a ${PREFIX}/lib
cp argp.h ${PREFIX}/include
