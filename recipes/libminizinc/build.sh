#!/bin/bash

mkdir build
cd build
cmake .. \
	-DCMAKE_INSTALL_PREFIX:PATH="$PREFIX"
cmake --build . --target install
