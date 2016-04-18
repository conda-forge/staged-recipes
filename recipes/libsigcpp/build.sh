#!/usr/bin/env bash

# set and verify flags
echo $CXX
CXXFLAGS=
LDFLAGS=
CFLAGS=
if [ "$(uname)" == "Darwin" ]; then
  CC=clang
  CXX=clang++
else
  CC=
  CXX=
fi
echo  $CPP
echo  $CXXCPP
echo  $M4
echo  $PERL
echo  $DOT
echo  $DOXYGEN
echo  $XSLTPROC
echo  $PKG_CONFIG
PKG_CONFIG_PATH=
echo  $PKG_CONFIG_LIBDIR
echo $ACLOCAL_FLAGS
echo 'int main(){return 0;}'>examples/hello_world.cc

# configure, make, install, check
./configure  --prefix=$PREFIX CFLAGS='-g -O2' CXXFLAGS='-g -O2' CPP= CXX=
make
make install
make check