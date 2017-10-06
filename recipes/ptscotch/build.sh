#!/bin/sh

cp $RECIPE_DIR/Makefile.inc.$(uname) src/Makefile.inc

cd src/
make ptesmumps | tee make.log 2>&1
make check
cd ..

# install.
mkdir -p $PREFIX/lib/
cp lib/libpt* $PREFIX/lib/
mkdir -p $PREFIX/bin/
cp bin/dg* $PREFIX/bin/
mkdir -p $PREFIX/include/
cp include/ptscotch*.h $PREFIX/include/
cp include/parmetis.h  $PREFIX/include/
