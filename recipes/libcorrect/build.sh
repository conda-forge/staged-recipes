#!/usr/bin/env bash

set -ex

mkdir build
cd build

cmake -G "Ninja" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  ${CMAKE_ARGS} \
  ..

cmake --build . --config Release -- -j${CPU_COUNT}
cmake --build . --config Release --target shim -- -j${CPU_COUNT}
cmake --build . --config Release --target install

cmake -E rm -f $PREFIX/lib/libcorrect.a $PREFIX/lib/libfec.a
