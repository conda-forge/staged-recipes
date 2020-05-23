#!/usr/bin/env bash
set -ex

scons APR="${PREFIX}" APU="${PREFIX}" \
    OPENSSL="$PREFIX" ZLIB="$PREFIX" \
    PREFIX="$PREFIX" CC="$CC" \
    CFLAGS="$CFLAGS" \
    CPPFLAGS="$CPPFLAGS" LINKFLAGS="$LDFLAGS"

scons install
