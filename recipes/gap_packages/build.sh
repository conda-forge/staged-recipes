#!/bin/bash

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* build-aux/ || true

./configure --prefix=$PREFIX --libdir=$PREFIX/lib --disable-static
make -j${CPU_COUNT}
make install

if [[ "$CONDA_BUILD_CROSS_COMPILATION" != 1 || "$CROSSCOMPILING_EMULATOR" != "" ]]; then
  make check
fi
