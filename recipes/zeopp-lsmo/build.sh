#!/bin/bash

cd voro++
make
cp src/voro++ ${PREFIX}/bin
cd ../

cd zeo++
make
cp network ${PREFIX}/bin
cd ../
