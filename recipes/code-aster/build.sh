#!/bin/bash
set -e

echo "**************** H O M A R D  B U I L D  S T A R T S  H E R E ****************"

cd homard

$PYTHON setup_homard.py --prefix=$PREFIX/bin -en -v

find $PREFIX -iname "homard*"

cd ..

echo "**************** H O M A R D  B U I L D  E N D S  H E R E ****************"

echo "**************** M E T I S  B U I L D  S T A R T S  H E R E ****************"

cd metis-aster

mkdir -p $PREFIX/metis-aster

make config \
     prefix=$PREFIX/metis-aster

make -j 1
make install

cd ..

echo "**************** M E T I S  B U I L D  E N D S  H E R E ****************"

echo "**************** M U M P S  B U I L D  S T A R T S  H E R E ****************"

cd mumps-aster

export LIBPATH="$PREFIX/metis-aster/lib $PREFIX/mumps-aster/lib $PREFIX/lib $LIBPATH"
export INCLUDES="$PREFIX/metis-aster/include $PREFIX/include $INCLUDES"
cp -f $RECIPE_DIR/contrib/waf-2.0.24 ./waf # To solve the StopIteration issue see https://www.code-aster.org/forum2/viewtopic.php?id=24617
$PYTHON waf configure install --prefix=${PREFIX}/mumps-aster --enable-metis --embed-metis --enable-scotch -j 1

cd ..

echo "**************** M U M P S  B U I L D  E N D S  H E R E ****************"

echo "**************** A S T E R  B U I L D  S T A R T S  H E R E ****************"

cp -Rf $RECIPE_DIR/contrib/asrun $SP_DIR/
cp -Rf $RECIPE_DIR/contrib/scripts/* $PREFIX/bin
export TFELHOME=$PREFIX
export LIBPATH="$PREFIX/metis-aster/lib $PREFIX/mumps-aster/lib $PREFIX/lib $LIBPATH"
export INCLUDES="$PREFIX/metis-aster/include $PREFIX/mumps-aster/include $PREFIX/mumps-aster/include_seq $PREFIX/include $INCLUDES"
./waf --prefix=$PREFIX --libdir=$PREFIX/lib --pythondir=$PREFIX/lib/aster --without-hg --enable-metis --embed-metis --enable-mumps --embed-mumps --install-tests --enable-mfront --disable-petsc configure
./waf build -j $CPU_COUNT
./waf install

find $PREFIX -name "profile.sh" -exec sed -i 's/PYTHONHOME=/#PYTHONHOME=/g' {} \;
find $PREFIX -name "profile.sh" -exec sed -i 's/export PYTHONHOME/#export PYTHONHOME/g' {} \;

mkdir -p $PREFIX/etc/codeaster/
cp -Rf $RECIPE_DIR/contrib/etc/* $PREFIX/etc/codeaster/

echo "**************** A S T E R  B U I L D  E N D S  H E R E ****************"

echo "**************** C L E A N U P  S T A R T S  H E R E ****************"

rm -Rf $PREFIX/metis-aster
rm -Rf $PREFIX/mumps-aster
rm -Rf $PREFIX/homard

echo "**************** C L E A N U P  E N D S  H E R E ****************"
