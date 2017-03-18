#!/bin/bash
set -ex

export CFLAGS="${CFLAGS} -O3 -fPIC -I${PREFIX}/include"
export CXXFLAGS="${CXXFLAGS} -O3 -fPIC -I${PREFIX}/include"
export LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib"
export CPPFLAGS="${CXXFLAGS}"

# Configure
./configure --prefix=$PREFIX

# Build
make -j$CPU_COUNT

# Install
make install
