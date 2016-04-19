#!/usr/bin/env bash

# set and verify flags
echo $CXX
export LDFLAGS=
export CFLAGS="-g -O2"
export CXXFLAGS="-g -O2"
if [ "$(uname)" == "Darwin" ]; then
  export CC=clang
  export CXX=clang++
  export CXXFLAGS="${CXXFLAGS} -stdlib=libc++ -std=c++11"
  export LDFLAGS="${LDFLAGS} -stdlib=libc++ -std=c++11"
else
  export CC=
  export CXX=
fi

echo  $CPP
echo  $CXXCPP
echo  $M4
echo  $PERL
echo  $DOT
echo  $DOXYGEN
echo  $XSLTPROC
echo  $PKG_CONFIG
export PKG_CONFIG_PATH=
echo  $PKG_CONFIG_LIBDIR
echo $ACLOCAL_FLAGS
echo 'int main(){return 0;}'>examples/hello_world.cc

# configure, make, install, check
#CC=${CC} CXX=${CXX} ./configure --prefix=$PREFIX CFLAGS='-g -O2' CXXFLAGS='-g -O2'
CC=${CC} CXX=${CXX} ./configure --prefix="${PREFIX}" \
  CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}"
make
make install
make check