#!/bin/bash
set -eu

make clean || true
export CFLAGS="${CFLAGS} -Wno-error"
if [[ "${PERL:-}" = "$PREFIX"* ]]; then
    export PERL=$BUILD_PREFIX/bin/perl
fi

if [[ "${OBSOLETE_API}" == "" ]]; then
    echo "Value for --enable-obsolete-api not given via OBSOLETE_API environment variable"
    exit 1
fi

./configure \
    --prefix="${PREFIX}" \
    --disable-static \
    --enable-hashes=strong,glibc \
    --enable-obsolete-api="${OBSOLETE_API}" \
    --disable-failure-tokens

make -j${CPU_COUNT}
make check

if [[ "${OBSOLETE_API}" == "glibc" ]]; then
    install -c .libs/libcrypt.so.1.* "$PREFIX/lib/"
    (cd "$PREFIX/lib" && ln -s -f libcrypt.so.1.* libcrypt.so.1)
else
    make install -j${CPU_COUNT}
fi
