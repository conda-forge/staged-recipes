#!/bin/sh
set -ex

mkdir -p out/release
cd out/release
CC=clang CXX=clang++ cmake -DCMAKE_INSTALL_PREFIX=$CONDA_PREFIX ../..
make
make install

