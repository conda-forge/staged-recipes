#!/bin/sh
set -eu

./autogen.sh
./configure --prefix="${PREFIX}" --host="${CONDA_TOOLCHAIN_HOST}" --disable-static
make -j"${CPU_COUNT}"
make install
