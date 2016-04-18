#!/bin/bash

if [[ `uname` == "Darwin" ]];
then
    export CC="clang"
    export CXX="clang++"
    export MACOSX_VERSION_MIN="10.7"
    export CXXFLAGS="-mmacosx-version-min=${MACOSX_VERSION_MIN}"
    export CXXFLAGS="${CXXFLAGS} -stdlib=libc++ -std=c++11"
    export LINKFLAGS="-mmacosx-version-min=${MACOSX_VERSION_MIN}"
    export LINKFLAGS="${LINKFLAGS} -stdlib=libc++ -std=c++11"
fi

./configure --prefix="${PREFIX}"
make
make check
make install

# Delete man pages.
rm -rf "${PREFIX}/share"
