#! /usr/bin/env bash

mkdir _build && cd _build

cmake .. \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release

make
make install
