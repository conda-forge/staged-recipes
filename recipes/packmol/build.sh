#!/bin/bash

sed -i.bak 's|FORTRAN=/usr/bin/gfortran|FORTRAN=${GFORTRAN}|g' Makefile

chmod +x configure
./configure
make
cp packmol ${PREFIX}/bin/
