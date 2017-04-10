#!/bin/bash

mkdir build && cd build
cmake \
	-DCMAKE_INSTALL_PREFIX=$PREFIX          \
	..
make
ctest -VV
make install
