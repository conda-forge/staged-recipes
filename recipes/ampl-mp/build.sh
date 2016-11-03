#!/bin/bash

if [ `uname` == "Darwin" ]; then
  export LDFLAGS="${LDFLAGS} -Wl,-rpath,$PREFIX/lib"
fi

mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=$PREFIX -DCMAKE_BUILD_TYPE=None \
 -DCMAKE_FIND_FRAMEWORK=LAST -DCMAKE_VERBOSE_MAKEFILE=ON -Wno-dev \
 -DBUILD_SHARED_LIBS=True ..

make
make test
make install
