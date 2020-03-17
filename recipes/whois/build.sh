#!/usr/bin/env bash
set -ex

make prefix=${PREFIX} -j ${CPU_COUNT}
# no make check
make prefix=${PREFIX} install
