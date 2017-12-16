#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir/bin
mkdir -p $PREFIX/bin

cd $SRC_DIR

mkdir build && cd build
cmake \
  -DCMAKE_INSTALL_PREFIX=$outdir \
  -DSTATICCOMPILE=ON \
  -DENABLE_PYTHON_INTERFACE=ON \
  -DENABLE_TESTING=OFF \
  ..

make install

ln -s $outdir/bin/cryptominisat5_simple $PREFIX/bin/cryptominisat_simple
