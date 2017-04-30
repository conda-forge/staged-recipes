#!/bin/bash

config_args="--enable-shared"
export LDFLAGS="$LDFLAGS -Wl,-rpath,${PREFIX}/lib"

./configure ${config_args}

make
make check
make install prefix=${PREFIX} exec_prefix=${PREFIX}
