#!/bin/bash

./configure \
    --with-sysroot=$PREFIX \
    --prefix=$PREFIX
# For a more complete configuration, the arch package is a great example:
# https://git.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/lighttpd

make -j${CPU_COUNT}

# See:
#  https://redmine.lighttpd.net/projects/lighttpd/wiki/RunningUnitTests
#  https://github.com/lighttpd/lighttpd1.4/tree/master/tests
make -j${CPU_COUNT} check VERBOSE=1
# This has 1 fail for mod_secdownload
# If we cannot find the cause, limit the tests to be run like: RUNTESTS="request core"

make install

rm -rf $PREFIX/bin
mv $PREFIX/sbin $PREFIX/bin
