#!/bin/bash
./bootstrap.sh
./configure --prefix=$PREFIX --with-boost-libdir=${PREFIX}/lib
make
make check 
make install 
