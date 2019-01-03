#!/bin/bash
set -e

# Fix header installation (FS#60246)
patch -p1 -i "${RECIPE_DIR}/header-install.patch"

# Apply Gentoo's libpng15 patch
patch < "${RECIPE_DIR}/libafterimage-libpng15.patch"


if [ "$(uname)" == "Linux" ]; then
    configure_args="--x-includes=\"${PREFIX}/include\" --x-libraries=\"${PREFIX}/lib\""
else
    configure_args="--without-x"
fi

./configure \
    --prefix="${PREFIX}" \
    --libdir="${PREFIX}/lib" \
    --mandir="${PREFIX}/share/man" \
    --enable-sharedlibs \
    --disable-staticlibs \
    --with-jpeg-includes="${PREFIX}/include" \
    --with-png-includes="${PREFIX}/include" \
    --with-tiff-includes="${PREFIX}/include" \
    --with-builtin-ungif \
    --disable-glx \
    --with-afterbase=no \
    ${configure_args}

# don't run ldconfig
sed -i -e 's/`uname`/"hack"/g' Makefile

make AR="${AR} clq" install
