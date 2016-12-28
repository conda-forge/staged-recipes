#!/bin/bash

mkdir build && cd build
cmake \
	-DCMAKE_INSTALL_PREFIX=$PREFIX          \
	-DCMAKE_BUILD_TYPE=Release              \
	..
make -j
make install
