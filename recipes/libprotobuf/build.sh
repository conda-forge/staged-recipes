#!/bin/bash


if [ "$(uname)" == "Darwin" ];
then
    # Switch to clang with C++11 ASAP.
    export CXXFLAGS="${CXXFLAGS} -stdlib=libc++ -std=c++11"
    export LIBS="-lc++"
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
