#!/bin/bash 
mkdir build && cd build
../cmake/configure --prefix=$PREFIX
make
make install
