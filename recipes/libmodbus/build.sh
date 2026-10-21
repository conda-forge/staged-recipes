#!/bin/sh
set -eu

./configure --prefix="${PREFIX}" --host="${CONDA_TOOLCHAIN_HOST}" --disable-static
make -j"${CPU_COUNT}"
make install
