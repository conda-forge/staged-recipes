#!/usr/bin/env bash
set -ex

./configure --prefix="$PREFIX" --with-system-metailor --with-system-mathic --with-system-mathicgb

make -j${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
make check
fi
make install
