#!/bin/bash

set -ex

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .

aclocal
autoreconf -vfi
INTLTOOL_PERL=$PREFIX/bin/perl ./configure --prefix=$PREFIX
make install
