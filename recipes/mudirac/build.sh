#!/bin/bash
mkdir -p build
cd build
cmake $SRC_DIR
make
ctest
mkdir -p $PREFIX/bin/
cp -r bin/mudirac $PREFIX/bin/
