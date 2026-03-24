#!/usr/bin/env bash

set -ex
CXXFLAGS="-std=c++11 $CXXFLAGS"
mkdir -p $PREFIX/lib $PREFIX/include
$CXX \
  $CXXFLAGS \
  -fPIC \
  -I./include \
  src/*.cpp \
  -o $PREFIX/lib/libhptt$SHLIB_EXT \
  -shared
cp include/*.h $PREFIX/include/
