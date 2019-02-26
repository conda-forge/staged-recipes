#!/bin/bash

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
