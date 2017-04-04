#!/bin/bash

mkdir build && cd build
cmake \
  -DWITH_CPP11=yes                        \
	-DCMAKE_INSTALL_PREFIX=$PREFIX          \
	..
make
make tests
make install
