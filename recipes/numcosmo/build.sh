#!/usr/bin/env bash

_PY=$PYTHON
export PYTHON="python"

./configure --prefix="${PREFIX}" --enable-opt-cflags

make -j$CPU_COUNT
make check -j$CPU_COUNT
make install -j$CPU_COUNT
