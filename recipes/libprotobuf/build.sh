#!/bin/bash


if [ "$(uname)" == "Darwin" ];
then
    # Switch to clang with C++11 ASAP.
    export MACOSX_VERSION_MIN=10.7
    export CC=clang
    export CXX=clang++
    export CXXFLAGS="-mmacosx-version-min=${MACOSX_VERSION_MIN}"
    export CXXFLAGS="${CXXFLAGS} -stdlib=libc++ -std=c++11 -O2"
    export LIBS="-lc++"
elif [ "$(uname)" == "Linux" ];
then
    export CC=gcc
    export CXX=g++
    export CXXFLAGS="-O2"
fi

# Doesn't include gmock or gtest. So, need to get these ourselves for `make check`.
git clone -b release-1.7.0 git://github.com/google/googlemock.git gmock
git clone -b release-1.7.0 git://github.com/google/googletest.git gmock/gtest

# Build configure/Makefile as they are not present.
aclocal
libtoolize
autoconf
autoreconf -i
automake --add-missing

./configure --prefix="${PREFIX}" \
            --with-pic \
            --enable-shared \
            --enable-static \
	    CC="${CC}" \
	    CXX="${CXX}" \
	    CXXFLAGS="${CXXFLAGS}" \
	    LDFLAGS="${LDFLAGS}"
make
make check
make install
