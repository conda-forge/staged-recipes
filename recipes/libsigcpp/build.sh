#!/usr/bin/env bash
export LIBRARY_PATH="${PREFIX}/lib"
export INCLUDE_PATH="${PREFIX}/include"

# set and verify flags
echo $CXX
#export LDFLAGS=
#export CFLAGS=#"-g -O2"
#export CXXFLAGS=#"-g -O2"
if [ "$(uname)" == "Darwin" ]; then
  export CC=clang
  export CXX=clang++
  export MACOSX_VERSION_MIN="10.7"
  export CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
  export CXXFLAGS="${CXXFLAGS} -stdlib=libc++ -std=c++11"
  export LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
  export LDFLAGS="${LDFLAGS} -stdlib=libc++ -std=c++11"
  export LINKFLAGS="${LDFLAGS}"
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
  CFLAGS="${CFLAGS}" CXXFLAGS="${CXXFLAGS}" LDFLAGS="${LDFLAGS}" || \
  cat config.log
make
make install
make check