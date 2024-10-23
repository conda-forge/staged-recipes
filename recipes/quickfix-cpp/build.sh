#! /bin/bash

set -ex

export CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"

sed -i.bak "s/glibtoolize/libtoolize/g" bootstrap

./bootstrap
./configure --prefix=${PREFIX} --host=${HOST} --with-python3

make -j"${CPU_COUNT}"
make check
make install
