#!/bin/bash
cmake -D CMAKE_INSTALL_PREFIX=$PREFIX \
.

make
make install
