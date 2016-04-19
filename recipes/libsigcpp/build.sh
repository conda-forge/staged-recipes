#!/usr/bin/env bash

# set and verify flags
export LIBRARY_PATH="${PREFIX}/lib"
export INCLUDE_PATH="${PREFIX}/include"
export LDFLAGS=
export CFLAGS="-O2"
export CXXFLAGS="-O2"
if [ "$(uname)" == "Darwin" ]; then
  # for Mac OSX
  export CC=clang
  export CXX=clang++
  export MACOSX_VERSION_MIN="10.7"
  export CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
  export CXXFLAGS="${CXXFLAGS} -stdlib=libc++ -std=c++11"
  export LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
  export LDFLAGS="${LDFLAGS} -stdlib=libc++ -std=c++11"
  export LINKFLAGS="${LDFLAGS}"
else
  # for linux
  export CC=
  export CXX=
fi
export PKG_CONFIG_PATH=
echo 'int main(){return 0;}'>examples/hello_world.cc

# configure, make, install, check
CC=${CC} CXX=${CXX} ./configure --prefix="${PREFIX}" \
  CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" || \
  cat config.log
make
make install
make check