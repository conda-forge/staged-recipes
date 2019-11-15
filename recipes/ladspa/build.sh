#!/usr/bin/env bash
set -ex

pushd src/
make -j ${CPU_COUNT}
# no make check
make install
