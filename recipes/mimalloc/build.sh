#!/bin/sh
set -ex

mkdir -p out/release
cd out/release
CC=clang CXX=clang++ CMAKE_INSTALL_PRECMAKE_INSTALL_PREFIX=$CONDA_PREFIX cmake ../..
make
make install
