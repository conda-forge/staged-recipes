#!/usr/bin/env bash

if [ $(uname) == Darwin ]; then
  export CC=clang
  export CXX=clang++
  export MACOSX_DEPLOYMENT_TARGET="10.9"
  export CXXFLAGS="-stdlib=libc++ $CXXFLAGS"
  export CXXFLAGS="$CXXFLAGS -stdlib=libc++"
fi



mkdir build_libradolan && cd build_libradolan
cmake -D CMAKE_INSTALL_PREFIX=$PREFIX \
      -D WITH_TESTS=YES \
      $SRC_DIR

make VERBOSE=1
make install
