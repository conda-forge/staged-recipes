#!/bin/bash

set -e

if [[ "$target_platform" == osx* ]]; then
  rm $PREFIX/lib/libcrypto.dylib
  rm $PREFIX/lib/libc++.*dylib
fi

$CXX $CXXFLAGS -I. -O3 -g0 -DLDID_NOSMIME -DLDID_NOPLIST -c -o ldid.o ldid.cpp
$CC $CFLAGS -I. -O3 -g0 -DLDID_NOSMIME -DLDID_NOPLIST -c -o lookup2.o lookup2.c
$CXX $CXXFLAGS -I. -O3 -g0 -o ldid ldid.o lookup2.o $LDFLAGS -lcrypto

mkdir -p $PREFIX/bin
cp ldid $PREFIX/bin

