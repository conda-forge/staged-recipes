#!/bin/bash
set -e

echo "**************** A S T E R  B U I L D  S T A R T S  H E R E ****************"

cp -Rf $RECIPE_DIR/contrib/asrun $SP_DIR/
cp -Rf $RECIPE_DIR/contrib/scripts/* $PREFIX/bin
export TFELHOME=$PREFIX
ls $PREFIX/metis-aster/lib
ls $PREFIX/metis-aster/include
ls $PREFIX/mumps-aster/lib
ls $PREFIX/mumps-aster/include

export LIBPATH="$PREFIX/metis-aster/lib $PREFIX/mumps-aster/lib $PREFIX/lib $LIBPATH"
export INCLUDES="$PREFIX/metis-aster/include $PREFIX/mumps-aster/include $PREFIX/mumps-aster/include_seq $PREFIX/include $INCLUDES"
./waf --prefix=$PREFIX --without-hg --enable-metis --embed-metis --enable-mumps --embed-mumps --install-tests --disable-petsc configure
./waf build -j $CPU_COUNT
./waf install

find $PREFIX -name "profile.sh" -exec sed -i 's/PYTHONHOME=/#PYTHONHOME=/g' {} \;
find $PREFIX -name "profile.sh" -exec sed -i 's/export PYTHONHOME/#export PYTHONHOME/g' {} \;

mkdir -p $PREFIX/etc/codeaster/
cp -Rf $RECIPE_DIR/contrib/etc/* $PREFIX/etc/codeaster/

echo "**************** A S T E R  B U I L D  E N D S  H E R E ****************"