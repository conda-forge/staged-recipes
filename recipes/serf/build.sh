#!/bin/bash

# SCons needs the full path to the C compiler.
export CC="$(which $CC)"

scons \
	PREFIX="${PREFIX}" \
	APR="${PREFIX}" \
	APU="${PREFIX}" \
	GSSAPI="${PREFIX}" \
	OPENSSL="${PREFIX}" \
	ZLIB="${PREFIX}" \
	CC="${CC}" \
	CPPFLAGS="${CPPFLAGS}" \
	CFLAGS="${CFLAGS}" \
	LINKFLAGS="${LDFLAGS}" \

scons install
