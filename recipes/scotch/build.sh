#!/bin/sh

cd src/

if [ `uname` == "Darwin" ]; then
    cp $RECIPE_DIR/Makefile.inc.i686_mac_darwin10 Makefile.inc
else
  cp $RECIPE_DIR/Makefile.inc.x86-64_pc_linux2.shlib Makefile.inc
  sed -i 's#-l$(SCOTCHLIB)errexit#-l$(SCOTCHLIB)errexit -lm#g' esmumps/Makefile
fi

make esmumps | tee make.log 2>&1
make check
cd ..

# install.
mkdir -p $PREFIX/lib/
cp lib/* $PREFIX/lib/
mkdir -p $PREFIX/bin/
cp bin/* $PREFIX/bin/
mkdir -p $PREFIX/include/
cp include/* $PREFIX/include/
