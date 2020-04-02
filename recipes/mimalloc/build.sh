#!/bin/sh
set -ex

mkdir -p out/release
cd out/release
CC=clang CXX=clang++ cmake ../..
make
make install
