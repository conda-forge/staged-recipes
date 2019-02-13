#!/usr/bin/env bash
set -eux

CC="$(basename "$CC")"
CXX="$(basename "$CXX")"

ln -s $BUILD_PREFIX/bin/$CC $BUILD_PREFIX/bin/cc
ln -s $BUILD_PREFIX/bin/$CXX $BUILD_PREFIX/bin/c++

./configure \
  --prefix=$PREFIX \
  --debug \
  --disable-internal-sqlite \
  --with-tcl=$PREFIX \
  --with-zlib=$PREFIX/include \
  --with-openssl=$PREFIX \
  --json

make --debug

make install --debug
