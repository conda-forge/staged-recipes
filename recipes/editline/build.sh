#!/usr/bin/env bash
set -ex

./configure --prefix="${PREFIX}"
make all -j ${CPU_COUNT}
make check
make install
