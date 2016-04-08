#!/bin/bash

export DYLD_LIBRARY_PATH="$PREFIX/lib:$DYLD_LIBRARY_PATH"
if [ "$(uname)" == "Darwin" ]; then
    export MACOSX_VERSION_MIN=10.7
    export CC="clang"
    export CXX="clang++"
    export CXXFLAGS="-mmacosx-version-min=${MACOSX_VERSION_MIN}"
    export CXXFLAGS="${CXXFLAGS} -stdlib=libc++ -std=c++11"
    export LINKFLAGS="-mmacosx-version-min=${MACOSX_VERSION_MIN}"
    export LINKFLAGS="${LINKFLAGS} -stdlib=libc++ -std=c++11 -L${LIBRARY_PATH}"
fi


"${PYTHON}" setup.py configure --zmq "${PREFIX}"
"${PYTHON}" setup.py install
