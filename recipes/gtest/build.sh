#!/bin/bash

# Copy headers
cp -r $SRC_DIR/include/gtest $PREFIX/include/

# Build and copy static libraries
mkdir build_static
cd build_static
cmake $SRC_DIR
make
cp libgtest.a $PREFIX/lib/
cp libgtest_main.a $PREFIX/lib/
cd $SRC_DIR

# Build and copy dynamic libraries
UNAME="$(uname)"
if [ "${UNAME}" == "Darwin" ]; then
  # for OS X
  LIBEXT="dylib"
else
  # for Linux
  LIBEXT="so"
fi

mkdir build_dynamic
cd build_dynamic
cmake $SRC_DIR -Dgtest_build_tests=ON
make
cp libgtest_dll.$LIBEXT $PREFIX/lib/
cd $SRC_DIR
