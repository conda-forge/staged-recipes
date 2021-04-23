#!/bin/bash

mkdir -p ${PREFIX}/bin
mkdir -p ${PREFIX}/lib

make
cp src/voro++ ${PREFIX}/bin/
cp src/libvoro++.a  ${PREFIX}/lib
