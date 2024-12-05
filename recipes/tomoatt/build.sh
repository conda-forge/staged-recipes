#!/bin/bash

set -e

git clone https://github.com/jbeder/yaml-cpp.git external_libs/yaml-cpp

mkdir build && cd build

export LDFLAGS="${LDFLAGS} -L${PREFIX}/lib"
export CPPFLAGS="${CPPFLAGS} -I${PREFIX}/include"

cmake ${CMAKE_ARGS} -D CMAKE_INSTALL_PREFIX=$PREFIX ..
make -j$CPU_COUNT
make install

