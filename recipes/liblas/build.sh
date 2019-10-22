#!/bin/bash

mkdir build
cd build

cmake -G "Unix Makefiles" \
  -DBoost_NO_BOOST_CMAKE=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DBoost_USE_STATIC_LIBS=no \
  ..

make -j${CPU_COUNT}
make install
