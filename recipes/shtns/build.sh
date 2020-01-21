#!/bin/bash
SHTNS="shtns-3.3.1-r694"
cd src
./configure --enable-python --disable-openmp --prefix=${PREFIX}
make
make install
