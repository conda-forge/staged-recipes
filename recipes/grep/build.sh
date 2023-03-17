#!/usr/bin/env bash

set -euxo pipefail

./configure                 \
    --prefix=${PREFIX}      \
    --build=${BUILD}        \
    --host=${HOST}          \
    --enable-threads=posix  \
    --enable-perl-regexp=yes

make -j${CPU_COUNT}

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  make check
fi

make install
