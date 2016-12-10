#!/bin/bash

if [ $(uname) == Darwin ]; then
    COMP_CC=clang
    COMP_CXX=clang++
    export MACOSX_DEPLOYMENT_TARGET="10.9"
    export CXXFLAGS="$CXXFLAGS -stdlib=libc++"
    export LDFLAGS="$LDFLAGS -headerpad_max_install_names"
else
    export LDFLAGS="$LDFLAGS -L$PREFIX/lib"
    export CPPFLAGS="$CPPFLAGS -I$PREFIX/include"
    export C_INCLUDE_PATH="$PREFIX/include"
    export LIBRARY_PATH="$PREFIX/lib"
fi

./configure --prefix=$PREFIX
make -j $CPU_COUNT
make check
make install
