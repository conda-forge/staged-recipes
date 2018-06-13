#!/bin/sh
if [[ `uname` == Darwin ]]; then
  export LDFLAGS="-Wl,-rpath,$PREFIX/lib $LDFLAGS"
fi

mkdir build
cd build
cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=$PREFIX ..
make install
