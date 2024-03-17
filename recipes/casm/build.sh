#!/bin/bash
./bootstrap.sh
./configure --prefix=$PREFIX --with-boost-libdir=${PREFIX}/lib CXXFLAGS="${CXXFLAGS}" CC="${CC}" CXX="${CXX}" PYTHON="${PYTHON}" LDFLAGS="${LDFLAGS}" CFLAGS="${CFLAGS}"
make
make check 
make install 
