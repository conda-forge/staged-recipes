#!/usr/bin/env bash
set -ex

./configure --prefix="${PREFIX}" \
            --enable-introspection \
            --enable-opengl \
            --enable-x264

make -j ${CPU_COUNT} ${VERBOSE_AT}
make check
make install
