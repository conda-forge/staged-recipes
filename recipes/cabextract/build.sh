#!/bin/bash
./configure
mkdir -p ${PREFIX}/lib
make
cp cabextract ${PREFIX}/bin/
