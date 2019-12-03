#!/usr/bin/env bash

set -e # Abort on error.

# find the boost libs/includes we need
export LDFLAGS="$LDFLAGS -L$PREFIX/lib -Wl,-rpath,$PREFIX/lib"
export CFLAGS="$CFLAGS -fPIC -I$PREFIX/include"

mkdir build && cd build

echo "which python"
which python
echo "python version"
python --version

cmake -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D ENABLE_PYTHON=1 \
      -D ENABLE_SSL=0 \
      -D BOOST_ROOT=$PREFIX \
      -D ECBUILD_LOG_LEVEL=DEBUG \
      -D Python3_ROOT_DIR=$PREFIX \
      -D Python3_FIND_VIRTUALENV=ONLY \
      ..

make -j $CPU_COUNT

make check

make install
