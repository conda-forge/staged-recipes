#!/usr/bin/env bash
set -ex

scons APR="$PREFIX" APU="$PREFIX" OPENSSL="$PREFIX" ZLIB="$PREFIX" \
    PREFIX="$PREFIX" CC="$CC" CPPFLAGS="$CPPFLAGS" LINKFLAGS="$LDFLAGS"

scons install
