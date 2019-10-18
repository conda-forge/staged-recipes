#!/usr/bin/env bash

if [[ "$(uname)" == "Darwin" ]]; then
    export ENABLE_BACKTRACE=no
else
    export ENABLE_BACKTRACE=yes
fi

mkdir build
cd build

cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DOBAKE_BUILD_TESTS=yes \
    -DOBAKE_INSTALL_LIBDIR=lib \
    -DOBAKE_WITH_LIBBACKTRACE=$ENABLE_BACKTRACE \
    ..

make -j${CPU_COUNT} VERBOSE=1

ctest --output-on-failure

make install
