#!/usr/bin/env bash

set -e # Abort on error.

export PYTHON=
export CFLAGS="$CFLAGS -fPIC -I$PREFIX/include"

mkdir ../build && cd ../build

if [[ $(uname) == Linux ]]; then
    RPCGEN_USE_CPP_ENV=1
else
    RPCGEN_USE_CPP_ENV=0
fi

cmake -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D ENABLE_DOCS=0 \
      -D RPCGEN_USE_CPP_ENV=$RPCGEN_USE_CPP_ENV \
      $SRC_DIR

make -j $CPU_COUNT

ctest --output-on-failure -j $CPU_COUNT
make install
