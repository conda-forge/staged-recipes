#!/bin/bash
set -euxo pipefail

./configure --prefix="${PREFIX}"

make -j"${CPU_COUNT:-1}"
make install PREFIX="${PREFIX}"
