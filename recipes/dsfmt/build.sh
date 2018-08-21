#!/usr/bin/env bash

make std
make std-check
make sse2-check

${CC} ${CFLAGS} -O3 -finline-functions -fomit-frame-pointer -DNDEBUG -DDSFMT_MEXP=19937 \
  -fPIC -fno-strict-aliasing --param max-inline-insns-single=1800 -Wmissing-prototypes \
  -Wall -std=c99 -shared dSFMT.c -o libdSFMT${SHLIB_EXT} ${LDFLAGS}

mkdir -p ${PREFIX}/lib
mkdir -p ${PREFIX}/include
cp libdSFMT${SHLIB_EXT} ${PREFIX}/lib
cp dSFMT.h ${PREFIX}/include
