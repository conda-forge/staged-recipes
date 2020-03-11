#!/bin/bash

mkdir -p build
cd build

if [ `uname` == Darwin ]; then
	export LS_USE_ZCHUNK=OFF;
else
	export LS_USE_ZCHUNK=ON;
fi

cmake -DCMAKE_INSTALL_PREFIX=$PREFIX \
      -DCMAKE_PREFIX_PATH=$PREFIX \
      -DCMAKE_INSTALL_LIBDIR=lib \
      -DBUILD_SHARED_LIBS=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DWITH_ZCHUNK=$LS_USE_ZCHUNK \
      ..

make VERBOSE=1 -j${CPU_COUNT}
make test
make install