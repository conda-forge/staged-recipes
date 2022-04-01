#!/bin/bash
set -exuo pipefail

cd browndye2
# makefile uses $CC, $CFLAGS, but it's actually C++
export CC=$CXX
export CFLAGS=$CXXFLAGS

make -j"${CPU_COUNT:-1}" all

test -d "${PREFIX}"/bin || mkdir -p "${PREFIX}"/bin
cp bin/* "${PREFIX}"/bin/
