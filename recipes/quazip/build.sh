#!/bin/bash

mkdir build

cmake -B build -S . ${CMAKE_ARGS} -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_INSTALL_LIBDIR=lib
cmake --build build
cmake --install build

