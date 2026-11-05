#!/bin/bash
set -euxo pipefail

./configure --prefix="${PREFIX}"
make -j"${CPU_COUNT}"
make install
