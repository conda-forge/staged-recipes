#!/usr/bin/env bash

set -e # Abort on error.

export PYTHON=
export CFLAGS="$CFLAGS -fPIC -I$PREFIX/include"

mkdir ../build && cd ../build

cmake -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D ENABLE_DOCS=0 \
      $SRC_DIR

make -j $CPU_COUNT

ctest --output-on-failure -j $CPU_COUNT
make install
