#!/bin/bash

if [[ $(uname) == Linux ]]; then
  # FIXME: This is a terrible workaround.
  # Ideally we should fix the information the .la files.
  rm -rf $PREFIX/lib/libquadmath.la
  rm -rf $PREFIX/lib/libgfortran.la
  OPTS="--enable-fortran=yes"
elif [[ $(uname) == Darwin ]]; then
  OPTS="--enable-fortran=no"
fi

./configure --prefix=$PREFIX \
            --enable-shared \
            $OPTS

make
make testing
make install

cp $RECIPE_DIR/license.txt $SRC_DIR/license.txt
