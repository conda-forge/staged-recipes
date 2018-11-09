#!/bin/bash
export F90=gfortran

cd src
make
make enum.x
make polya.x

cp enum.x $PREFIX/bin
cp polya.x $PREFIX/bin