#!/bin/sh

cd src/
echo 'prefix = $PREFIX' > Makefile.inc
echo '' >> Makefile.inc
if [ `uname` == "Darwin" ]; then
    cp Make.inc/Makefile.inc.i686_mac_darwin10 Makefile.inc
    sed -i '' 's/-DSCOTCH_PTHREAD//g' Makefile.inc
    sed -i '' 's/-O3/-O3 -fPIC/g' Makefile.inc
else
  cp Make.inc/Makefile.inc.x86-64_pc_linux2 Makefile.inc
  sed -i "s@CFLAGS\t\t=@CFLAGS\t= -I${PREFIX}/include@" Makefile.inc
  sed -i "s@CLIBFLAGS\t=@CLIBFLAGS\t= -fPIC@g" Makefile.inc
  sed -i 's#-l$(SCOTCHLIB)errexit#-l$(SCOTCHLIB)errexit -lm#g' esmumps/Makefile
fi
make esmumps | tee make.log 2>&1
cd ..

# install.
mkdir -p $PREFIX/lib/
cp lib/* $PREFIX/lib/
mkdir -p $PREFIX/bin/
cp bin/* $PREFIX/bin/
mkdir -p $PREFIX/include/
cp include/* $PREFIX/include/
