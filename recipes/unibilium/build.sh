#!/usr/bin/env bash

set -o xtrace -o nounset -o pipefail -o errexit

make
make install "PREFIX=${PREFIX}"
