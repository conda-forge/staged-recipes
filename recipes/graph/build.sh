#!/bin/bash

mkdir build && cd build
cmake \
	-DCMAKE_INSTALL_PREFIX=$PREFIX          \
	..
make

if [[ "$(uname)" != "Darwin" ]]; then
	ctest
fi

make install
