#!/bin/bash

set -exuo pipefail

VALAC=/no-valac ./configure --prefix=${PREFIX}
make -j${CPU_COUNT}
make install

make check
