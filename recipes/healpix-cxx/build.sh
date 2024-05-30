#! /bin/bash
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/libtool/build-aux/config.* .

set -ex

./configure --prefix=$PREFIX
make install
