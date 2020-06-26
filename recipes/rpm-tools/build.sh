#!/usr/bin/env bash

./configure \
    --prefix="${PREFIX}"  \
    --enable-python \
    --with-external-db \
    --with-lua \
    --with-cap \
    PYTHON="${PYTHON}"

make "-j${CPU_COUNT}" install
make check
make installcheck

"${PYTHON}" -m pip install ./python -vv
