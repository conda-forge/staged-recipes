#!/bin/bash

set -euo pipefail

cd $SRC_DIR

./autogen.sh

./configure \
      --prefix=$PREFIX \
      --libdir=$PREFIX/lib \
      --includedir=$PREFIX/include \
      --disable-kernel-module \
      --disable-static \
      --enable-shared

make -j${CPU_COUNT}

make install

# Clean up libtool .la file — not needed by consumers
rm -f $PREFIX/lib/libxpmem.la

