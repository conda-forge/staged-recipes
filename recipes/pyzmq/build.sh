#!/bin/bash

export DYLD_LIBRARY_PATH="$PREFIX/lib:$DYLD_LIBRARY_PATH"
if [ "$(uname)" == "Darwin" ]; then
    MACOSX_VERSION_MIN=10.7
    CC="clang"
    CXX="clang++"
    CXXFLAGS="-mmacosx-version-min=${MACOSX_VERSION_MIN}"
    CXXFLAGS="${CXXFLAGS} -stdlib=libc++ -std=c++11"
    LINKFLAGS="-mmacosx-version-min=${MACOSX_VERSION_MIN}"
    LINKFLAGS="${LINKFLAGS} -stdlib=libc++ -std=c++11 -L${LIBRARY_PATH}"
fi


"$PYTHON" setup.py configure --zmq "$PREFIX"
"$PYTHON" setup.py install
