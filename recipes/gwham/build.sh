#!/bin/bash
mkdir -p $PREFIX/bin
cd "wham_${PKG_VERSION}"
cd wham
make clean
make
mv wham $PREFIX/bin
cd ../wham-2d
make clean
make
mv wham-2d $PREFIX/bin
