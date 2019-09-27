#!/bin/sh



mkdir build && cd build 

cmake -D PRISMATIC_ENABLE_GUI=1 \
	-D CMAKE_INSTALL_PREFIX=$PREFIX \
	../ 

make

make install
