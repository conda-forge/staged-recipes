#!/usr/bin/env bash

set -euxo pipefail

./configure            \
    --prefix=${PREFIX} \
    --build=${BUILD}   \
    --host=${HOST}     \
    --disable-static

make -j${CPU_COUNT} all

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR:-}" != "" ]]; then
  XDG_CACHE_HOME=`pwd`/.cache make check
fi

make install
