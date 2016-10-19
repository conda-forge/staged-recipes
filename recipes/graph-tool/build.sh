#!/usr/bin/env bash

export BOOST_ROOT="${PREFIX}/lib"

aclocal -I m4 --install
./autogen.sh
BOOST_ROOT="${PREFIX}/lib" \
CPPFLAGS="-I${PREFIX}/include" \
CXXFLAGS="-I${PREFIX}/include" \
./configure --prefix="${PREFIX}"

make
make install
exit 0
