#!/usr/bin/env bash
set -x

if [[ $target_platform == linux-* ]]; then
    export CPPFLAGS="$CPPFLAGS -fPIE"
fi

make -j${CPU_COUNT} \
    CC="$CC" \
    CFLAGS="$CFLAGS" \
    CPPFLAGS="$CPPFLAGS" \
    FFLAGS="$FFLAGS" \
    LDFLAGS="$LDFLAGS"

mkdir -p $PREFIX/bin \
    $PREFIX/lib \
    $PREFIX/include \

rm -rf bin/*.dSYM
cp -a bin/* $PREFIX/bin
cp -a libwcs/libwcs.a $PREFIX/lib
cp -a libwcs/*.h $PREFIX/include
