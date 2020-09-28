#!/usr/bin/env bash

./configure --prefix="${PREFIX}" --enable-strip

make "-j${CPU_COUNT}" LDFLAGS="${LDFLAGS}" check

make "-j${CPU_COUNT}" LDFLAGS="${LDFLAGS}" install
