#!/bin/bash


mkdir build

cmake -B build -S . -DCMAKE_INSTALL_PREFIX=$PREFIX -G Ninja
cmake --build build
DESTDIR=$PREVIX cmake --install build

