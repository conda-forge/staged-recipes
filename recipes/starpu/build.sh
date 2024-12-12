#!/bin/bash
set -ex

./autogen.sh

# Configure
./configure \
    --prefix=$PREFIX \
    --enable-shared \
    --with-hwloc=$PREFIX \
    --disable-static

# Build and install
make -j$(nproc)
make install