#!/usr/bin/env bash

mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX:PATH=$PREFIX ..
make install
