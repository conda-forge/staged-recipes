#!/bin/bash

# Avoid weird messages that confuse py6s
# export FFLAGS="-ffpe-summary=none"

cmake -D CMAKE_INSTALL_PREFIX=$PREFIX \
.

make
make install
