#!/bin/bash
mkdir build && cd build
../configure --prefix=${PREFIX} --with-zlib=${PREFIX}/lib 
make
make install
