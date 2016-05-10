#!/bin/env bash

BOOST_ROOT=$PREFIX
ZLIB_ROOT=$PREFIX
LIBEVENT_ROOT=$PREFIX

export OPENSSL_ROOT=$PREFIX
export OPENSSL_ROOT_DIR=$PREFIX

if [ "$(uname)" == "Darwin" ]; then
  # C++11 finagling for Mac OSX
  export CC=clang
  export CXX=clang++
  export MACOSX_VERSION_MIN="10.7"
  export CXXFLAGS="${CXXFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
  export CXXFLAGS="${CXXFLAGS} -stdlib=libc++ -std=c++11"
  export LDFLAGS="${LDFLAGS} -mmacosx-version-min=${MACOSX_VERSION_MIN}"
  export LDFLAGS="${LDFLAGS} -stdlib=libc++ -std=c++11"
  export LINKFLAGS="${LDFLAGS}"
  export MACOSX_DEPLOYMENT_TARGET=10.7
fi

cmake \
	-DBUILD_PYTHON=off \
	-DBUILD_JAVA=off \
	-DBUILD_C_GLIB=off \
	.

make
make check
make install
