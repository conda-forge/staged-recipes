#!/bin/bash
set -ex

# Install to conda style directories
[[ -d lib64 ]] && mv lib64 lib

mkdir -p $PREFIX/include
cp -vrp include/* $PREFIX/include/

mkdir -p $PREFIX/lib
cp -vrpd lib/* $PREFIX/lib/

check-glibc "$PREFIX"/lib*/*.so.*
