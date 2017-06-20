#!/usr/bin/env bash

export LDFLAGS="$LDFLAGS -Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib -lz"
./autogen.sh
./configure --prefix="${PREFIX}"
make
make test
make -j${CPU_COUNT} install
