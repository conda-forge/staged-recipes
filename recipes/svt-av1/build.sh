#!/bin/bash

set -ex

cd Build

if [[ $target_platform == linux-* ]]; then
    export LIBS="$LIBS -lrt"  # for clock_gettime
    export LDFLAGS="$LDFLAGS -lrt"  # for clock_gettime
fi

cmake ${CMAKE_ARGS} \
      -DCMAKE_BUILD_TYPE=Release \
      ..


make -j${CPU_COUNT} VERBOSE=1

make install
