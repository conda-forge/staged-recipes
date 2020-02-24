#!/bin/bash

mkdir build
cd build

cmake -G Ninja \
    -D CMAKE_INSTALL_PREFIX:FILEPATH=$PREFIX \
    -D PYTHONOCC_BUILD_TYPE:STRING=Release \
    -D Python3_FIND_STRATEGY:STRING=LOCATION \
    -D Python3_FIND_FRAMEWORK:STRING=NEVER \
    -D SWIG_HIDE_WARNINGS:BOOL=ON \
    ..

ninja install