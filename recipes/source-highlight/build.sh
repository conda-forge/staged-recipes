#!/bin/bash

autoreconf -i
mkdir build
cd build
../configure --prefix=$PREFIX
make
make install
