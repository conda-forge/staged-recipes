#!/usr/bin/env bash

./configure --prefix=$PREFIX
make
make install

mkdir -p $PREFIX/etc/conda/activate.d/
echo "source $PREFIX/lmod/lmod/init/profile" > $PREFIX/etc/conda/activate.d/lmod-activate.sh
chmod a+x $PREFIX/etc/conda/activate.d/lmod-activate.sh

#exit 1
