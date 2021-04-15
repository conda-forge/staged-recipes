#!/usr/bin/env bash
set -ex

autoreconf -i
./configure --prefix="$PREFIX"
#            --enable-introspection

#            --enable-opengl     \
#            --enable-x264 \

make -j ${CPU_COUNT}
make check
make install
