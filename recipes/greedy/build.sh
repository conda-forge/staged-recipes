#!/usr/bin/env bash

mkdir build
cd build


ccmake ../greedy \
      -DCMAKE_BUILD_TYPE=Release \
      -DUSE_FFTW=OFF \
      ..

make
