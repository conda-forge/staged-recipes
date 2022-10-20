#!/usr/bin/env bash
#
# The following modifications have been made to prevent collision
# with the "wcslib" package:
#   - The "libwcs" library has been renamed to "libwcstools"
#   - The headers have been moved to "include/wcstools"
#
set -x

bindir=$PREFIX/bin
incdir=$PREFIX/include
libdir=$PREFIX/lib
datadir=$PREFIX/share
mandir=$datadir/man

# Prepare library linkage
LIBWCS="-L./libwcs -lwcstools $LDFLAGS"
libsuffix="so"
if [[ $target_platform == osx-* ]]; then
    libsuffix="dylib"
    LIBWCS="$LIBWCS -Wl,-headerpad_max_install_names"
fi
libname="libwcstools.${libsuffix}"
    
# Force position independant code generation
export CFLAGS="$CFLAGS -fPIC"

# Short circuit:
#   - Build the static archive without compiling the programs
#   - The static archive is omitted from the package
pushd libwcs
    make -j${CPU_COUNT} \
        CC="$CC" \
        CFLAGS="$CFLAGS" \
        CPPFLAGS="$CPPFLAGS" \
        FFLAGS="$FFLAGS" \
        LDFLAGS="$LDFLAGS"

    # Build the shared library
    $CC -shared -lm -o "$libname" *.o
popd

# Override LIBWCS variable:
#   - Link to the shared library instead of the static archive
make CC="$CC" LIBWCS="$LIBWCS"

# Remove debug artifacts (osx specific)
rm -rf bin/*.dSYM

# The makefile doesn't provide an install target.
mkdir -p $bindir \
    $libdir/pkgconfig \
    $incdir/wcstools \
    $mandir

cp -a wcstools bin/* $bindir
cp -a man/man1 $mandir
cp -a libwcs/$libname $libdir
cp -a libwcs/*.h $incdir/wcstools
sed -e "s|@PREFIX@|$PREFIX|;s|@PKG_NAME@|$PKG_NAME|;s|@PKG_VERSION@|$PKG_VERSION|" \
    $RECIPE_DIR/wcstools.pc.in > $libdir/pkgconfig/wcstools.pc

# Normalize permissions
chmod -R 755 $bindir $libdir/$libname
find $incdir $libdir/pkgconfig $mandir \
    -type f \
    -exec chmod 644 '{}' \;
