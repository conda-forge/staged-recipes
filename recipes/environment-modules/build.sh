#!/usr/bin/env bash

set -x -e

./configure --prefix=$PREFIX --with-tcl=$PREFIX/lib

make
make install

mkdir -p $PREFIX/etc/conda/activate.d/
echo "source $PREFIX/Modules/3.2.10/init/bash" > $PREFIX/etc/conda/activate.d/environment-modules-activate.sh
chmod a+x $PREFIX/etc/conda/activate.d/environment-modules-activate.sh
