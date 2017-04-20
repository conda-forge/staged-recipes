#!/bin/bash

# To be used if pulling the sources from git
#./autogen.sh                   || exit 1

./configure --prefix="$PREFIX" || exit 1
make -j${CPU_COUNT}            || exit 1
make check -j${CPU_COUNT}      || exit 1
make install
