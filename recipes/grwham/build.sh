#!/bin/bash
mkdir -p $PREFIX/bin
cd "wham_${PKG_VERSION}"
mkdir -p $PREFIX/share/grwham
curl -o $PREFIX/share/grwham/doc.pdf http://membrane.urmc.rochester.edu/sites/default/files/wham/doc.pdf
cd wham
# Use the given $(CC)
sed -i -e 's/CC=gcc//g' Makefile
make clean
make
mv wham $PREFIX/bin
cd ../wham-2d
# Use the given $(CC)
sed -i -e 's/CC=gcc//g' Makefile
make clean
make
mv wham-2d $PREFIX/bin
