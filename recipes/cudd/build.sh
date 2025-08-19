#!/bin/bash

pushd "$SRC_DIR" || exit

autoreconf -vfi

./configure \
  CFLAGS="-fPIC -std=c99" \
  --enable-shared \
  --prefix="$PREFIX"

make -j "$CPU_COUNT"
make install

popd || exit
