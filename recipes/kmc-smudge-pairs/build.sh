#!/bin/sh

make -j "${CPU_COUNT}" CXX="$CXX" LDFLAGS="$LDFLAGS" CXXFLAGS="$CXXFLAGS" -f makefile_shared

mkdir -p $PREFIX/bin
cp ./bin/* $PREFIX/bin/
