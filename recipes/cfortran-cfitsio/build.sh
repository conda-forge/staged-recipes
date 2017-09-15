#!/bin/bash

cfortran=$(find . -name "cfortran.h")
f77_wrap=$(find . -name "f77_wrap.h")

# Install additional headers
mkdir -p ${PREFIX}/include

cp ${cfortran} ${PREFIX}/include
cp ${f77_wrap} ${PREFIX}/include

