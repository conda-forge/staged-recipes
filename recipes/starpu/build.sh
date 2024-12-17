#!/bin/bash
set -ex

libtoolize --force --copy
./autogen.sh

# Configure
./configure \
    --prefix=$PREFIX \
    --enable-shared \
    --with-hwloc=$PREFIX \
    --disable-static

echo "#### begin config.log ####"
cat config.log
echo "#### end config.log ####"

# Build and install
make -j$(nproc)
make install
make check
