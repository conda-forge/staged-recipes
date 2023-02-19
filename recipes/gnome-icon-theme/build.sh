#!/bin/bash

set -ex

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

aclocal
libtoolize
autoconf
autoreconf -i
automake
INTLTOOL_PERL=$PREFIX/bin/perl ./configure --prefix=$PREFIX
make install
