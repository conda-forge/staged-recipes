#!/bin/bash

set -eux

mkdir -p "$PREFIX"/{lib,include}
${CC} ${CPPFLAGS} ${CFLAGS} ${LDFLAGS} -shared -fPIC -o libcutest.so CuTest.c
cp libcutest.so "${PREFIX}/lib/"
cp CuTest.h "${PREFIX}/include/"
