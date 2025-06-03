#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make -j${CPU_COUNT}
make -j${CPU_COUNT} test
make -j${CPU_COUNT} PREFIX=${PREFIX} install
