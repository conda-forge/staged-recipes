#!/bin/bash

mkdir atatbin
cd atat
make -j3 
sed -i "s|BINDIR=\$(HOME)/bin/|BINDIR=$(pwd)/../atatbin|g" makefile
make install ../atatbin
cp ../atatbin/* ${PREFIX}/bin
cp -r data ${PREFIX}/atat_data
