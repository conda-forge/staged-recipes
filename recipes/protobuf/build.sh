#!/bin/bash


if [ "$(uname)" == "Darwin" ];
then
    # Switch to clang with C++11 ASAP.
    export MACOSX_VERSION_MIN=10.7
    export CC=clang
    export CXX=clang++
    export CXXFLAGS="-mmacosx-version-min=${MACOSX_VERSION_MIN}"
    export CXXFLAGS="${CXXFLAGS} -stdlib=libc++ -std=c++11"
    export LIBS="-lc++"
elif [ "$(uname)" == "Linux" ];
then
    export CC=gcc
    export CXX=g++
fi

./autogen.sh
./configure --prefix="${PREFIX}" \
            --with-pic \
            --enable-shared \
            --enable-static \
	    CC="${CC}" \
	    CXX="${CXX}" \
	    CXXFLAGS="${CXXFLAGS} -O2" \
	    LDFLAGS="${LDFLAGS}"
make -j ${CPU_COUNT}
make check -j ${CPU_COUNT}
make install
(cd python && python setup.py install --cpp_implementation --single-version-externally-managed --record record.txt && cd ..)
