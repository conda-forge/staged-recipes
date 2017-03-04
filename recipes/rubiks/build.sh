#!/bin/bash

export LD_LIBRARY_PATH=$PREFIX/lib:$LD_LIBRARY_PATH
export LDFLAGS="-L$PREFIX/lib $LDFLAGS"
export CFLAGS="-O3 -g -I$PREFIX/include $CFLAGS"
export CXXFLAGS="-O3 -g -I$PREFIX/include $CXXFLAGS"
export INSTALL="install"

export CPP=${CXX}
export LINK=${CXX}
make -e install PREFIX="$PREFIX"

touch LICENSE.txt
echo "rubiks is licensed under the following 3 licenses" >> LICENSE.txt
echo "==========================================================================" >> LICENSE.txt
cat dietz/license.txt >> LICENSE.txt
echo "==========================================================================" >> LICENSE.txt
cat dik/license.txt >> LICENSE.txt
echo "\n==========================================================================" >> LICENSE.txt
cat reid/license.txt >> LICENSE.txt

cat LICENSE.txt
