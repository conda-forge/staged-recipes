#!/bin/bash

declare -a _scons_xtra_flags
_scons_xtra_flags+=(--dbg=off)
_scons_xtra_flags+=(--disable-warnings-as-errors)
_scons_xtra_flags+=(--enable-free-mon=on)
_scons_xtra_flags+=(--enable-http-client=on)
_scons_xtra_flags+=(--mmapv1=on)
_scons_xtra_flags+=(--mobile-se=on)
_scons_xtra_flags+=(--opt=on)
_scons_xtra_flags+=(--prefix=$PREFIX)
_scons_xtra_flags+=(--release)
_scons_xtra_flags+=(--server-js=on)
_scons_xtra_flags+=(--ssl=on --ssl-provider=openssl)
_scons_xtra_flags+=(--wiredtiger=on)
_scons_xtra_flags+=(CC="$CC" CXX="$CXX" OBJCOPY="$OBJCOPY")
_scons_xtra_flags+=(CCFLAGS="$CFLAGS" CXXFLAGS="$CXXFLAGS" LINKFLAGS="$LDFLAGS")
_scons_xtra_flags+=(HOST_ARCH="$HOST")
_scons_xtra_flags+=(RPATH="$PREFIX/lib")
_scons_xtra_flags+=(VERBOSE=on)
_scons_xtra_flags+=(--use-system-{boost,icu,pcre,sqlite,snappy,yaml,zlib,zstd,abseil-cpp})

$PYTHON buildscripts/scons.py install core "${_scons_xtra_flags[@]}"
