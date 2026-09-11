#!/bin/bash
set -ex

./configure --prefix=$PREFIX
make -j"${CPU_COUNT}" AR="${AR}" RANLIB="${RANLIB}" sdk plugins host rdfgen

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR:-}" != "" ]]; then
    make AR="${AR}" RANLIB="${RANLIB}" test
fi

make AR="${AR}" RANLIB="${RANLIB}" install
