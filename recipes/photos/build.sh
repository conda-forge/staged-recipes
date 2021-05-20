#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

autoconf
./configure --prefix="${PREFIX}" --with-hepmc="${PREFIX}" --with-hepmc3="${PREFIX}"
# Yes, LD=CXX is intentional..
make -j${CPU_COUNT} LD=$CXX
make install
