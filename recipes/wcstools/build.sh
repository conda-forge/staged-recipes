#!/usr/bin/env bash
set -x

# Select platform library suffix
libsuffix="so"
if [[ $target_platform == osx-* ]]; then
    libsuffix=dylib
fi

# Force position independant code generation
export CFLAGS="$CFLAGS -fPIC"

# Build
make -j${CPU_COUNT} \
    CC="$CC" \
    CFLAGS="$CFLAGS" \
    CPPFLAGS="$CPPFLAGS" \
    FFLAGS="$FFLAGS" \
    LDFLAGS="$LDFLAGS"

# The makefile doesn't provide a shared library target
pushd libwcs
    $CC -shared -lm -o libwcs.${libsuffix} *.o
popd

# Remove debug artifacts (osx specific)
rm -rf bin/*.dSYM

# The makefile doesn't provide an install target.
# Do it manually.
mkdir -p $PREFIX/bin \
    $PREFIX/lib \
    $PREFIX/lib/pkgconfig \
    $PREFIX/include \
    $PREFIX/share/man

cp -a wcstools bin/* $PREFIX/bin
cp -a man/man1 $PREFIX/share/man
cp -a libwcs/libwcs.${libsuffix} $PREFIX/lib
cp -a libwcs/*.h $PREFIX/include
sed -e "s|@PREFIX@|$PREFIX|;s|@PKG_NAME@|$PKG_NAME|;s|@PKG_VERSION@|$PKG_VERSION|" \
    $RECIPE_DIR/wcstools.pc.in > $PREFIX/lib/pkgconfig/wcstools.pc

# Normalize permissions
chmod 755 $PREFIX/bin/* $PREFIX/lib/libwcs.${libsuffix}
chmod 644 $PREFIX/include/*.h
