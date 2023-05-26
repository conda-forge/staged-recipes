#! /usr/bin/env bash
mkdir build && cd build

cmake .. \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DGRIB=ON \
  -DNCDF=ON \
  -DOPENGL=OFF

cmake --build . --target install --config Release