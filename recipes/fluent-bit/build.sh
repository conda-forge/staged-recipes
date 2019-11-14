#!/usr/bin/env bash

cd build
cmake \
  -DCMAKE_INSTALL_PREFIX:PATH="$PREFIX" \
  -DCMAKE_PREFIX_PATH:PATH="$PREFIX" \
  ../

make install
