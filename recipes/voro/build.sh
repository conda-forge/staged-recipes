#!/bin/bash

mkdir -p ${PREFIX}/bin

cd voro++
make
cp src/voro++ ${PREFIX}/bin/
cd ../
