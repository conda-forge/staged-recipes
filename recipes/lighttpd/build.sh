#!/bin/bash

./configure \
    --with-sysroot=$PREFIX \
    --prefix=$PREFIX \
    --with-webdav-props \
		--with-webdav-locks \
    --with-krb5 \
    --with-mysql \
    --with-openssl
#
# For a more complete configuration, the arch package is a great example:
# https://git.archlinux.org/svntogit/packages.git/tree/trunk/PKGBUILD?h=packages/lighttpd
#
# Some of dependencies for optional mods are not in CF yet (e.g. libldap or gdbm).
#
# We could consider adding a post-link hook to acho a message about
# optional dependencies (e.g. I would not depend on mysql at runtime,
# even if we do build with support for it).
#

make -j${CPU_COUNT}

# See:
#  https://redmine.lighttpd.net/projects/lighttpd/wiki/RunningUnitTests
#  https://github.com/lighttpd/lighttpd1.4/tree/master/tests
make -j${CPU_COUNT} check VERBOSE=1

make install

rm -rf $PREFIX/bin
mv $PREFIX/sbin $PREFIX/bin
