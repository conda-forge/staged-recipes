#!/bin/sh
if [[ `uname` == Darwin ]]; then
  export LDFLAGS="-Wl,-rpath,$PREFIX/lib $LDFLAGS"
fi

# Using autoconf
./autogen.sh
./configure
make check
make install

# Using cmake
# mkdir build
# cd build
# cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=$PREFIX ..
# make check
# make install
