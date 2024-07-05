#! /bin/bash

set -ex

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

./bootstrap
./configure --prefix=${PREFIX} --host=${HOST}

make -j"${CPU_COUNT}"
make check
make install
