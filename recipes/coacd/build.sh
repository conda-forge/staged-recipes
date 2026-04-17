#!/bin/sh
set -ex

cmake -LAH -G "Ninja" \
  -DWITH_3RD_PARTY_LIBS=OFF \
  -B build ${CMAKE_ARGS} .
cmake --build build --target install
