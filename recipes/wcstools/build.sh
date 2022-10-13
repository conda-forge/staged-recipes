#!/usr/bin/env bash
set -x

# Select platform library suffix
libsuffix="so"
if [[ $target_platform == osx-* ]]; then
    libsuffix="dylib"
fi

# Force position independant code generation
export CFLAGS="$CFLAGS -fPIC"

# Short circuit:
#   Build the static archive without compiling the programs
pushd libwcs
    make -j${CPU_COUNT} \
        CC="$CC" \
        CFLAGS="$CFLAGS" \
        CPPFLAGS="$CPPFLAGS" \
        FFLAGS="$FFLAGS" \
        LDFLAGS="$LDFLAGS"

    # Build the shared library
    $CC -shared -lm -o libwcs.${libsuffix} *.o
popd

rdelim="="
if [[ $target_platform == osx-* ]]; then
    rdelim=","
fi

# The top-level makefile only supports CFLAGS
# Override LIBWCS variable:
#   Link to the shared library instead of the static archive
make LIBWCS="-L./libwcs -lwcs -Wl,-rpath${rdelim}$PREFIX/lib"

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
chmod -R 755 $PREFIX/bin $PREFIX/lib/libwcs.${libsuffix}
find $PREFIX/include $PREFIX/lib/pkgconfig $PREFIX/share/man -type f \
    | xargs -I'{}' chmod 644 '{}'
