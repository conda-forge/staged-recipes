#! /bin/bash

# Build a bunch of X.org packages at once. The list of packages below should
# be kept synchronized with make-tarball.sh.

set -e

export PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig

if [ -n "$OSX_ARCH" ] ; then
    export MACOSX_DEPLOYMENT_TARGET=10.6
    sdk=/
    export CFLAGS="$CFLAGS -isysroot $sdk"
    export LDFLAGS="$LDFLAGS -Wl,-syslibroot,$sdk"
fi

# Work around weird packaging bug? (See also how we weirdly need to give
# xextproto --disable-specs.)
cp xcb-proto-*/missing xextproto-*/

# Note that `-e` mode doesn't cause us to exit when the inner pipelines fail,
# even though they exit with error codes.
(cd util-macros-* && ./configure --prefix=$PREFIX && make install) || exit $?
(cd xproto-* && ./configure --prefix=$PREFIX && make install) || exit $?
(cd xcb-proto-* && ./configure --prefix=$PREFIX && make install) || exit $?
(cd xextproto-* && ./configure --prefix=$PREFIX --disable-specs && make install) || exit $?
(cd fixesproto-* && ./configure --prefix=$PREFIX && make install) || exit $?
(cd kbproto-* && ./configure --prefix=$PREFIX && make install) || exit $?
(cd inputproto-* && ./configure --prefix=$PREFIX && make install) || exit $?
(cd recordproto-* && ./configure --prefix=$PREFIX && make install) || exit $?
(cd renderproto-* && ./configure --prefix=$PREFIX && make install) || exit $?
(cd xtrans-* && ./configure --prefix=$PREFIX && make install) || exit $?
(cd libpthread-stubs-* && ./configure --prefix=$PREFIX && make && make install) || exit $?
(cd libICE-* && ./configure --prefix=$PREFIX && make && make install) || exit $?
(cd libSM-* && ./configure --prefix=$PREFIX && make && make install) || exit $?
(cd libXau-* && ./configure --prefix=$PREFIX && make && make install) || exit $?
(cd libXdmcp-* && ./configure --prefix=$PREFIX && make && make install) || exit $?
(cd libxcb-* && ./configure --prefix=$PREFIX --enable-xinput && make && make install) || exit $?
(cd libX11-* && ./configure --prefix=$PREFIX && make && make install) || exit $?
(cd libXext-* && ./configure --prefix=$PREFIX && make && make install) || exit $?
(cd libXfixes-* && ./configure --prefix=$PREFIX && make && make install) || exit $?
(cd libXi-* && ./configure --prefix=$PREFIX && make && make install) || exit $?
(cd libXtst-* && ./configure --prefix=$PREFIX && make && make install) || exit $?
(cd libXrender-* && ./configure --prefix=$PREFIX && make && make install) || exit $?
(cd libXcursor-* && ./configure --prefix=$PREFIX && make && make install) || exit $?
(cd libXt-* && ./configure --prefix=$PREFIX && make && make install) || exit $?
(cd libXmu-* && ./configure --prefix=$PREFIX && make && make install) || exit $?
(cd libXpm-* && ./configure --prefix=$PREFIX && make && make install) || exit $?
(cd libXaw-* && ./configure --prefix=$PREFIX && make && make install) || exit $?
(cd libXaw3d-* && ./configure --prefix=$PREFIX && make && make install) || exit $?
(cd imake-* && ./configure --prefix=$PREFIX && make && make install) || exit $?
(cd xorg-cf-files-* && ./configure --prefix=$PREFIX && make && make install) || exit $?
(cd gccmakedep-* && ./configure --prefix=$PREFIX && make && make install) || exit $?

cd $PREFIX
rm -rf share/doc share/man lib/python2.7/site-packages/xcbgen
rm -f lib/*.a lib/*.la
