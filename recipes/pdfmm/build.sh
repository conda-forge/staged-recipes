#!/usr/bin/env bash

CC=clang
CXX=clang++

# configure cmake
cmake -B build -DCMAKE_PREFIX_PATH=${PREFIX} -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_STANDARD=17

# build
cmake --build build -DCMAKE_PREFIX_PATH=${PREFIX}

# install
cmake --install build --prefix=${PREFIX}
