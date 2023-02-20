#!/bin/bash

set -ex

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* .
cp $PREFIX/share/aclocal/gettext.m4 ./m4
cp $PREFIX/share/aclocal/iconv.m4 ./m4
cp $PREFIX/share/aclocal/intltool.m4 ./m4
cp $PREFIX/share/aclocal/nls.m4 ./m4

aclocal --force
autoupdate --force
libtoolize --force
intltoolize --copy --force --automake
autoconf --force
# autoreconf -i -f --verbose
automake --force --add-missing
INTLTOOL_PERL=$PREFIX/bin/perl ./configure --prefix=$PREFIX
INTLTOOL_PERL=$PREFIX/bin/perl make install
