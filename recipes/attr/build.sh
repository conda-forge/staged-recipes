#!/usr/bin/env bash
set -ex

./configure --prefix="${PREFIX}" --disable-static
make -j ${CPU_COUNT}
make install install-dev install-lib
