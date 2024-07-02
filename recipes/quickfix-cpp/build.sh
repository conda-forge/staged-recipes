#! /bin/bash

set -ex

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

./bootstrap
./configure --prefix=${PREFIX} --host=${HOST}

make
make check
make install
