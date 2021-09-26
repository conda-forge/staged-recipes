#!/bin/bash


mkdir build

cmake -B build -S . ${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=$PREFIX -G Ninja
cmake --build build
DESTDIR=$PREVIX cmake --install build
