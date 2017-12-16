#!/bin/bash
set -eu -o pipefail

outdir=$PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
mkdir -p $outdir/bin
mkdir -p $PREFIX/bin

cd $SRC_DIR

mkdir build && cd build
cmake \
  -DCMAKE_INSTALL_PREFIX=$outdir/bin \
  -DSTATICCOMPILE=ON \
  -DENABLE_PYTHON_INTERFACE=OFF \
  ..

make install
ldconfig

ln -s $outdir/bin/bin/cryptominisat5_simple $PREFIX/bin/cryptominisat
