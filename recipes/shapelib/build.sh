#!/usr/bin/env bash

if [ $(uname) == Darwin ]; then
  export CC=clang
  export CXX=clang++
  export MACOSX_DEPLOYMENT_TARGET="10.9"
  export CXXFLAGS="-stdlib=libc++ $CXXFLAGS"
  export CXXFLAGS="$CXXFLAGS -stdlib=libc++"
fi

mkdir build_shapelib && cd build_shapelib
cmake -D CMAKE_INSTALL_PREFIX=$PREFIX \
      $SRC_DIR

make VERBOSE=1
ctest
make install
