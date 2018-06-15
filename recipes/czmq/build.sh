#!/bin/sh
set -euo pipefail

if [[ `uname` == Darwin ]]; then
  export LDFLAGS="-Wl,-rpath,$PREFIX/lib $LDFLAGS"
fi

# Copy zmq library without version if not already existing

# Using autoconf
# ./autogen.sh
# ./configure --prefix="$PREFIX"
# make check
# make install

# Using cmake
mkdir build
cd build
cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_PREFIX_PATH=$PREFIX -D CMAKE_INCLUDE_PATH="$PREFIX/include" -D CMAKE_LIBRARY_PATH="$PREFIX/lib" -D CMAKE_C_FLAGS_RELEASE="-MT" -D CMAKE_CXX_FLAGS_RELEASE="-MT" -D CMAKE_C_FLAGS_DEBUG="-MTd" -D CMAKE_INSTALL_PREFIX=$PREFIX ..
# cmake -D CMAKE_BUILD_TYPE=Release -D CMAKE_INSTALL_PREFIX=$PREFIX ..
make all VERBOSE=1
ctest -V
make install
